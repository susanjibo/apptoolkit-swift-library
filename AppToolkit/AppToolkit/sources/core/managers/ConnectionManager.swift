//
//  ConnectionManager.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

protocol ConnectivityManager {
    var onConnectionMessage: ((String) -> ())? { get set }
    var onConnectionStateChange: ((Bool, Error?) -> ())?  { get set }
    
    init(robot: Robot, certificate: CertificateInfo)
    func connect() -> Promise<Bool>
    func disconnect() -> Promise<Bool>
    func sendRequest<T: Mappable>(_ request: T)
}

/**
 Interfaces with WebSocketConnection and delegates responses
 */
final class ConnectionManager: ConnectivityManager {
    fileprivate var connection: Connectivity
    var onConnectionMessage: ((String) -> ())?
    var onConnectionStateChange: ((Bool, Error?) -> ())?

    required init (connection: Connectivity) {
        self.connection = connection
        setupCallbacks()
    }
    
    convenience init(robot: Robot, certificate: CertificateInfo) {
        let connection = WebSocketConnection(robot.ip, port: robot.port, certificate: certificate)
        self.init(connection: connection)
    }
    
    func connect() -> Promise<Bool> {
        return Promise { [weak self] (fulfill, reject) in
            self?.connection.start().then { success -> () in
                fulfill(success)
            }.catch { error in
                reject(error)
            }
        }
    }

    func disconnect() -> Promise<Bool> {
        return Promise { [weak self] (fulfill, reject) in
            self?.connection.stop().then { success -> () in
                fulfill(success)
            }.catch { error in
                reject(error)
            }
        }
    }

    func sendRequest<T: Mappable>(_ request: T) {
        connection.sendRequest(request)
    }
}

// MARK: - ConnectivityDelegate
extension ConnectionManager {
    fileprivate func setupCallbacks() {
        connection.onTextMessage = { [unowned self] (text) in
            self.onConnectionMessage?(text)
        }
        
        connection.onConnectedChange = { [unowned self] (b, err) in
            self.onConnectionStateChange?(b, err)
        }
    }
}
