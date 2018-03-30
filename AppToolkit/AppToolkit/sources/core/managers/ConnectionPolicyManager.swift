//
//  ServerConnectionManager.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/30/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import PromiseKit
import Reachability

protocol ConnectionPolicyManagerProtocol {
	
	var requester: CommandRequester? { get }
	var connectionManager: ConnectivityManager? { get }
    var currentRobot: Robot? { get }

	// MARK: - Connection state
	var onConnectionStateChange: CommandLibrary.ConnectionStateChangeHandler? { get set }
	
	// MARK: API interface
	func authenticate(completion: @escaping CommandLibrary.CompletionHandler)
	func invalidate(completion: @escaping CommandLibrary.CompletionHandler)
	
	func connect(robot: Robot, completion: CommandLibrary.CompletionHandler?)
	func disconnect(completion: CommandLibrary.CompletionHandler?)
	
}

fileprivate struct ConnectionConstants {
	private init() {}
	
	static let maxRetryCount = 50
}

final class ConnectionPolicyManager: ConnectionPolicyManagerProtocol {
	
	// MARK: - Connection state
	var onConnectionStateChange: CommandLibrary.ConnectionStateChangeHandler?
	fileprivate var connectionRetryCount: Int = 0
    private(set) var currentRobot: Robot? = nil

	fileprivate let authManager: AuthManagerProtocol
	fileprivate var lock = NSLock()
	internal private(set) var requester: CommandRequester?
	internal private(set) var connectionManager: ConnectivityManager?
    private let reachability = Reachability()!

	private var isManualInitiatedDisconnect: Bool

	
	init(authManager: AuthManagerProtocol) {
		self.authManager = authManager
		self.isManualInitiatedDisconnect = false
        configReachability()
	}
	
    // MARK: API interface
	func authenticate(completion: @escaping CommandLibrary.CompletionHandler) {
		authManager.authenticate()
			.then { (success) -> () in
				completion(success, nil)
			}.catch { error in
				completion(false, error)
		}
	}
	
	func invalidate(completion: @escaping CommandLibrary.CompletionHandler) {
		authManager.invalidate()
		disconnect { (success, error) in
			completion(success, error)
		}
	}
	
    func connect(robot: Robot, completion: CommandLibrary.CompletionHandler? = nil) {
        // toggle manual disconnection flag (see disconnect for details)
        self.isManualInitiatedDisconnect = false
        self.currentRobot = nil
        guard reachability.connection == .wifi else {
            completion?(false, ApiError.noInternet)
            return
        }

        // Check if there is stored token and try to refetch if it is expired
		checkAuthenticationStatusAndRepairIfPossible(robotInfo: robot.info).then { [unowned self] succeeded -> () in
            if !succeeded {
                completion?(false, ApiError.notAuthorized)
            } else {
                self.currentRobot = robot
                
                // setup facilities
				self.setupManagers{ [unowned self] (success, error) in
					if success {
						self.requester?.connect().then { success -> () in
							print("Connected: \(success)")
							completion?(success, nil)
						}.catch { error in
							completion?(false, error)
						}
					} else {
						completion?(success, error)
					}
				}
            }
		}.catch { error in
			completion?(false, error)
        }
    }
	
	func disconnect(completion: CommandLibrary.CompletionHandler? = nil) {
        // set manual disconnection flag, it is needed to separate connection loss (due to bad WiFi or so) from manual disconnection
        isManualInitiatedDisconnect = true
        currentRobot = nil
		if let requester = requester {
			requester.disconnect().then { success -> () in
				completion?(success, nil)
				}.catch { error in
					completion?(false, error)
			}
		} else {
			completion?(true, nil)
		}
	}
	
	// MARK: - Private
	private func setupManagers(_ completion: @escaping CommandLibrary.CompletionHandler) {
        guard let robot = currentRobot else {
            completion(false, ApiError.badRequest)
            return
        }
		authManager.certificate(for: robot).then { [unowned self] (certificate) -> () in
            let connManager = ConnectionManager(robot: robot, certificate: certificate)
            
            // setup 'connection state change' callback
			connManager.onConnectionStateChange = { [unowned self] (b, err) in
                if let err = err {
                    print("Connection state changed error: \(err.localizedDescription), code: \((err as NSError?)?.code ?? -1) ")
                }
				
                // cleanup 'retry connection' counter
				self.cleanOutConnectionStateCounterIfNeeded(onConnectionsState: b)
                
                guard self.reachability.connection == .wifi else {
                    completion(false, ApiError.noInternet)
                    return
                }
                
                defer {
                    self.onConnectionStateChange?(b, err)
                }
                
                // try to reconnect
				self.reconnectIfNeeded(for: robot, connectionState: b, error: err)
			}
			self.requester = Requester(connectionManager: connManager, robotName: robot.info.name!)
			self.connectionManager = connManager
			completion(true, nil)
		}.catch { error in
			completion(false, error)
		}
	}
	
    // Performs automatic reconnection for 'connection loss' case
	private func reconnectIfNeeded(for robot: Robot, connectionState connected: Bool, error: Error?) {
		if !shouldRetryConnect(connectionState: connected, error: error) { return }
		print("Trying to reconnect \(connectionRetryCount+1) time(s)...")
		
		DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 0.1) { [weak self] in
			guard let sself = self else { return }
			
			sself.lock.lock(); defer { sself.lock.unlock() }
			sself.connectionRetryCount += 1
			sself.connect(robot: robot)
		}
    }
	
	private func shouldRetryConnect(connectionState connected: Bool, error: Error?) -> Bool {
		return !isManualInitiatedDisconnect
			&& !connected
			&& !isDisconnectedByRobot(with: error)
			&& !isSSLHandshakeError(error)
			&& !isConnectionRetryCountLimitRunOut()
	}
	
	private func isSSLHandshakeError(_ error: Error?) -> Bool {
		guard let error = error as NSError? else {
			return false
		}
		
		return error.code == errSSLClosedAbort
	}
	
	private func isDisconnectedByRobot(with error: Error?) -> Bool {
		guard let error = error as NSError? else {
			return false
		}
		
		return RobotDisconnectCode(rawValue: error.code) != nil
	}
	
	private func isConnectionRetryCountLimitRunOut() -> Bool {
		return connectionRetryCount >= ConnectionConstants.maxRetryCount
	}
	
	private func cleanOutConnectionStateCounterIfNeeded(onConnectionsState state: Bool) {
		if state { self.connectionRetryCount = 0 }
	}
	
	private func checkAuthenticationStatusAndRepairIfPossible(robotInfo: RobotInfoProtocol) -> Promise<Bool> {
        guard !CommandLibrary.useSimulator else { return Promise<Bool>(value: true) }
        
		let (promise, fulfill, reject) = Promise<Bool>.pending()
		
		switch authManager.authState {
		case .authorized:
			fulfill(true)
			break
		case .authorizedButTokenMissed:
			guard let clientInfo = ClientInfo.makeInfo() else {
				fulfill(false)
				return promise
			}
			authManager.refreshToken(clientInfo: clientInfo).then { [unowned self] refreshed -> Promise<Robot?> in
				guard refreshed else { throw ApiError.tokenRefreshFailed }
				return self.authManager.getIpAddress(robot: robotInfo)
			}.then { _ in
				fulfill(true)
			}.catch { error in
				reject(error)
			}
		case .notAuthorized:
			reject(ApiError.notAuthorized)
		default:
			reject(ApiError.notAuthorized)
		}
		
		return promise
	}

    private func configReachability() {
        reachability.allowsCellularConnection = false
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Failed to start reachability...")
        }
        
    }
}
