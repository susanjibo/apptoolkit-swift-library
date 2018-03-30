//
//  Requester.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/2/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper

protocol CommandRequester {
    typealias CommandCallback = CommandLibraryInterface.CallbackClosure

    func getSessionId() -> String?
    
    func connect() -> Promise<Bool>
    func disconnect() -> Promise<Bool>
    func getConfig(_ callback: CommandCallback?) -> CommandTransaction<Never>
    func setConfig(_ options: SetConfigOptionsProtocol, callback: CommandCallback?) -> CommandTransaction<Never>
	func cancel(transactionId: String) -> Promise<CancelResponse>
    func takeVideo(videoType: VideoType, duration: TimeInterval, callback: CommandCallback?, finalizer: TockenFinalizer?) -> CommandTransaction<Never>
    func takePhoto(with camera: Camera, resolution: CameraResolution, distortion: Bool, callback: CommandCallback?, finalizer: TockenFinalizer?) -> CommandTransaction<Never>
	func lookAt(targetType: LookAtTargetType, trackFlag: Bool, levelHeadFlag: Bool, callback: CommandCallback?) -> CommandTransaction<Never>
	func say(phrase: String, callback: CommandCallback?) -> CommandTransaction<Never>
    func entityRequest(callback: CommandCallback?) -> CommandTransaction<Never>

    func displayEye(in view: String, callback: CommandCallback?) -> CommandTransaction<Never>
    func displayText(_ text: String, in view: String, callback: CommandCallback?) -> CommandTransaction<Never>
    func displayImage(_ image: ImageData, in view: String, callback: CommandCallback?) -> CommandTransaction<Never>

    func getMotion(callback: CommandCallback?) -> CommandTransaction<Never>

    func listenForSpeech(maxSpeechTimeOut: Timeout, maxNoSpeechTimeout: Timeout, languageCode: LangCode, callback: CommandCallback?) -> CommandTransaction<Never>

    func listenForHeadTouch(callback: CommandCallback?) -> CommandTransaction<Never>

    func fetchAssetWithURI(_ uri: String, name: String, callback: CommandCallback?) -> CommandTransaction<Never>

    func listenForScreenGesture(_ params: ScreenGestureListenParams, callback: CommandCallback?) -> CommandTransaction<Never>
}

struct CommandTransaction<T> {
    let transactionId: TransactionID?
    let tokenAcknowledged: Promise<T>
}

class Requester {
    fileprivate var appId: String? = ""
    fileprivate var sessionId: String? = nil
    fileprivate var robotVersion: String? = "1.0" //default API version
    fileprivate var robotName: String
    fileprivate var pendingTokens: Dictionary<String, CommandTokenProtocol> = [:] // set of command tokens that are currently 'in progress'
    fileprivate var failedCommand: CommandTransaction<Never> {
        return CommandTransaction(transactionId: nil, tokenAcknowledged: Promise(error: CommandError.commandFailedInit))
    }

    fileprivate var connectionManager: ConnectivityManager

    required init(connectionManager: ConnectivityManager, robotName: String) {
        self.robotName = robotName
        self.connectionManager = connectionManager
        self.connectionManager.onConnectionMessage = {[unowned self] message in
            self.didReceiveConnectionMessage(message)
        }
    }

    deinit {
        // flush pending tokens
        pendingTokens.forEach { (token) in
            let (_, t) = token
            t.forceComplete(with: CommandError.commandFailedInit)
        }
    }

    func getSessionId() -> String? {
        return sessionId
    }
    
    func sendToken<T, R>(_ token: CommandToken<T, R>) {
        if let request = Request<T>() {
            request.command = token.command

            // 1. Send command
            sendRequest(request, transactionId: token.transactionId)
            
            // 2. Store command token for further handling
            if let transactionId = token.transactionId, (!token.isComplete) {
                pendingTokens[transactionId] = token
            }
        }
    }
    
    fileprivate func startSession() -> Promise<Bool> {
        guard getSessionId() == nil else {
            return Promise<Bool>(value: true)
        }

        return Promise { (fulfill, reject) in
            if let startSessionCommand = CommandMaker<StartSessionCommand>.makeCommand() {
                let token = StartSessionToken(startSessionCommand, transactionId: robotName.transactionId())
                token.complete().then { [unowned self] (result) -> () in
                    self.robotVersion = result.sessionInfo?.version
                    self.sessionId = result.sessionInfo?.sessionId
                    fulfill(true)
                }.catch { (e) in
                    print("Start session failed: \(e)")
                    reject(e)
                }
                sendToken(token)
            }
        }
    }
	
    struct CommandMaker<T: BaseCommand> {
        fileprivate static func makeCommand() -> T? {
            return T()
        }
    }

    fileprivate func sendRequest<T>(_ request: Request<T>?, transactionId: TransactionID?) {
        if let request = request,
            let header = RequestHeader() {
            // setup request fields
            header.transactionId = transactionId
            header.appId = appId
            header.version = robotVersion
            header.sessionId = getSessionId()
            request.header = header
            
            connectionManager.sendRequest(request)
        }
    }
}

// MARK: - CommandRequester
extension Requester: CommandRequester {
    func connect() -> Promise<Bool> {
        return Promise { [weak self] (fulfill, reject) in
            self?.connectionManager.connect().then { success -> () in
                self?.startSession().then { success -> () in
                    fulfill(success)
                }.catch { error in
                    reject(error)
                }
            }.catch { error in
                reject(error)
            }
        }
    }

    func disconnect() -> Promise<Bool> {
        return Promise { [weak self] (fulfill, reject) in
            self?.connectionManager.disconnect().then { success -> () in
                self?.pendingTokens.removeAll()
                self?.sessionId = nil
                self?.robotVersion = "1.0"
                fulfill(success)
            }.catch { error in
                reject(error)
            }
        }
    }

    func getConfig(_ callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let getConfigCommand = CommandMaker<GetConfigCommand>.makeCommand() else { return failedCommand }
        
        let token = GetConfigToken(getConfigCommand, transactionId: robotName.transactionId())
        token.callback = callback
        
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
	}
	
    func setConfig(_ options: SetConfigOptionsProtocol, callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let setConfigCommand = SetConfigCommand(options) else { return failedCommand }
        
        let token = SetConfigToken(setConfigCommand, transactionId: robotName.transactionId())
        token.callback = callback
        
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }
    
	func takeVideo(videoType: VideoType = .normal, duration: TimeInterval, callback: CommandCallback?, finalizer: TockenFinalizer?) -> CommandTransaction<Never> {
        guard let takeVideoCommand = VideoCommand(videoType: videoType, duration: duration) else { return failedCommand }
        let token = VideoToken(takeVideoCommand, transactionId: robotName.transactionId())
        token.callback = callback
        token.finalizer = finalizer
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
	}
	
    func takePhoto(with camera: Camera, resolution: CameraResolution, distortion: Bool, callback: CommandCallback?, finalizer: TockenFinalizer?) -> CommandTransaction<Never> {
        guard let takePhotoCommand = TakePhotoCommand(camera: camera, resolution: resolution, distortion:distortion) else { return failedCommand }
        let token = TakePhotoToken(takePhotoCommand, transactionId: robotName.transactionId())
        token.callback = callback
        token.finalizer = finalizer
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
            }.catch { error in
                reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }

    func lookAt(targetType: LookAtTargetType, trackFlag: Bool = true, levelHeadFlag: Bool = true, callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let lookAtCommand = LookAtCommand(lookAtTargetType: targetType, trackFlag: trackFlag, levelHeadFlag: levelHeadFlag) else { return failedCommand }
        let token = LookAtToken(lookAtCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
            }.catch { error in
                reject(error)
            }
            self?.sendToken(token)
        }
		return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
	}
	
	func say(phrase: String, callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let sayCommand = SayCommand(phrase: phrase) else { return failedCommand }
        let token = SayToken(sayCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
            }.catch { error in
                reject(error)
            }
			self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
	}

    func entityRequest(callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let entityRequest = EntityRequest() else { return failedCommand }
        let token = EntityRequestToken(entityRequest, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
            }.catch { error in
                reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }

    func cancel(transactionId: String) -> Promise<CancelResponse> {
		return Promise { (fullfill, reject) in
			if let cancelCommand = CancelCommand(transactionId: transactionId) {
				let token = CancelToken(cancelCommand, transactionId: robotName.transactionId())
				token.complete().then { [unowned self] result -> () in
                    self.processCancel(result.cancelledTransactionId)
					fullfill(result)
				}.catch { error in
					print("Cancel command \(transactionId) failed: \(error)")
					reject(error)
				}
				self.sendToken(token)
			}
		}
	}
    
    func displayEye(in view: String, callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let view = EyeView(name: view), let displayCommand = DisplayCommand(view) else { return failedCommand }
        
        let token = DisplayToken(displayCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }
    
    func displayText(_ text: String, in view: String, callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let view = TextView(text, name: view), let displayCommand = DisplayCommand(view) else { return failedCommand }
        
        let token = DisplayToken(displayCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }
    
    func displayImage(_ image: ImageData, in view: String, callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let image = DisplayImage(image), let view = ImageView(image, name: view), let displayCommand = DisplayCommand(view) else { return failedCommand }
        
        let token = DisplayToken(displayCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }

    func getMotion(callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        guard let motionCommand = MotionRequest() else { return failedCommand }
        
        let token = MotionToken(motionCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }
    
    func listenForSpeech(maxSpeechTimeOut: Timeout, maxNoSpeechTimeout: Timeout, languageCode: LangCode, callback: CommandRequester.CommandCallback?) -> CommandTransaction<Never> {
        guard let listenCommand = ListenCommand(maxSpeechTimeOut: maxSpeechTimeOut, maxNoSpeechTimeout: maxNoSpeechTimeout, languageCode: languageCode) else { return failedCommand }
        
        let token = ListenToken(listenCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }

    func listenForHeadTouch(callback: CommandRequester.CommandCallback?) -> CommandTransaction<Never> {
        guard let headTouchCommand = HeadTouchRequest() else { return failedCommand }
        
        let token = HeadTouchToken(headTouchCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }
    
    func fetchAssetWithURI(_ uri: String, name: String, callback: CommandRequester.CommandCallback?) -> CommandTransaction<Never> {
        guard let fetchAssetCommand = FetchAssetCommand(uri: uri, name: name) else { return failedCommand }
        
        let token = FetchAssetToken(fetchAssetCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }
    
    func listenForScreenGesture(_ params: ScreenGestureListenParams, callback: CommandCallback?) -> CommandTransaction<Never> {
        guard let screenGestureCommand = ScreenGestureRequest(ScreenGestureFilter(params)) else { return failedCommand }
        
        let token = ScreenGestureToken(screenGestureCommand, transactionId: robotName.transactionId())
        token.callback = callback
        let tokenPromise: Promise<Never> = Promise { [weak self] (fulfill, reject) in
            token.complete().then { result -> () in
                fulfill(result)
                }.catch { error in
                    reject(error)
            }
            self?.sendToken(token)
        }
        return CommandTransaction(transactionId: token.transactionId, tokenAcknowledged: tokenPromise)
    }

}

// MARK: -
extension Requester {
    
    // Handles messages from robot
    func didReceiveConnectionMessage(_ message: String) {
        print("Message received for Requester instance \(self):\(Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque())")
        // Check if we can construct response from JSON
        if let response: RobotResponse = Mapper<ResponseBase>().map(JSONString: message) {
            var ack: Acknowledgement? = nil
            var evt: EventMessage? = nil
            var transactionId: TransactionID? = nil
            
            // Only two types of messages allowed: aknowledges and events
            if response.isAcknowledgement() {
                ack = response as? Acknowledgement
                transactionId = ack?.header?.transactionID
            } else if response.isEvent() {
                evt = response as? EventMessage
                transactionId = evt?.header?.transactionID
            } else {
                print("Invalid message received: \(message)")
            }
            
            if let id = transactionId {
                if let token = pendingTokens[id] {
                    if let ack = ack {
                        token.handleAcknowledgement(ack)
                    } else if let evt = evt {
                        token.handleEvent(evt)
                    }
                    
                    // If command token is marked as completed - perform additonal cleanup steps
                    if (token.isComplete) {
                        token.finalize()
                        pendingTokens[id] = nil
                    }
                }
            }
        }
    }
}

extension Requester {
    
    fileprivate func processCancel(_ transactionId: String? ) {
        if let id = transactionId, let token = pendingTokens[id] {
            token.finalize()
            pendingTokens[id] = nil
        }
    }
}
