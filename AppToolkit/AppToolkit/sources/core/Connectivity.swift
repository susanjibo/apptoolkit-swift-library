//
//  Connectivity.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 9/28/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import Starscream
import ObjectMapper
import PromiseKit
import ReactiveSwift

protocol Connectivity {
    func start() -> Promise<Bool>
    func stop() -> Promise<Bool>
    func sendRequest<T: Mappable>(_ request: T)

    var onTextMessage: ((String) -> ())? { get set }
    var onDataMessage: ((Data) -> ())? { get set }
    var onConnectedChange: ((Bool, Error?) -> ())? { get set }
}
//MARK: Connectivity
/// Reason the app was exited or connection was lost
public enum RobotDisconnectCode: Int {
	/// 4000: The Remote app was exited via head touch on robot
	case headTouchExit = 4000
	/// 4001: The Remote app was exited due to an error on the robot resulting in the error display taking over.
	case robotError = 4001
	/// 4002: A new Remote connection is superseding the existing one.
	case newConnection = 4002
	/// 4003: The connection was closed due to inactivity (no commands sent)
	case inactivityTimeout = 4003
}

enum SocketConnectionState: Equatable {
    case undefined
    case connecting
    case connected
    case disconnecting
    case disconnected(err: Error?)

    public static func ==(lhs: SocketConnectionState, rhs: SocketConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.undefined, .undefined),
             (.connecting, .connecting),
             (.connected, .connected),
             (.disconnecting, .disconnecting):
            return true
        case let (.disconnected(err1), .disconnected(err2)):
            return err1?.localizedDescription == err2?.localizedDescription
        default:
            return false
        }
    }
}

class WebSocketConnection: Connectivity {
    fileprivate var socket: WebSocket
    fileprivate var connected: MutableProperty<SocketConnectionState> = MutableProperty<SocketConnectionState>(.undefined)
    var onTextMessage: ((String) -> ())?
    var onDataMessage: ((Data) -> ())?
    var onConnectedChange: ((Bool, Error?) -> ())?
    private static var socketSchema: String {
        // separate schema for simulator flow
        return CommandLibrary.useSimulator ? "ws://" : "wss://"
    }

    required init(_ address: String, port: Int, certificate: CertificateInfo) {
        socket = WebSocket(url: URL(string: "\(WebSocketConnection.socketSchema)\(address):\(port)/")!)
        socket.security = SocketSecurity(certificate)
        socket.disableSSLCertValidation = true
        socket.clientCertificates = certificate.clientCerts()

        socket.onText = { [unowned self] (text) in
            print("Received text: \(text)")
            self.onTextMessage?(text)
        }
        socket.onData = { [unowned self] (data) in
            print("Received data: \(data.count)")
            self.onDataMessage?(data)
        }
        
        socket.onConnect = { [unowned self] in
            self.connected.value = .connected
            print("websocket is connected")
            self.onConnectedChange?(true, nil)
        }
        socket.onDisconnect = { [unowned self] (error) in
            self.connected.value = .disconnected(err: error)
            if let e = error {
                print("websocket is disconnected: \(e.localizedDescription)")
            } else {
                print("websocket disconnected")
            }
            self.onConnectedChange?(false, error)
        }
    }
    
    // Async method, tries to establish connection and returns 'isConnected' flag
    func start() -> Promise<Bool> {
        guard !socket.isConnected else { return Promise(value: true) }
        
        // state machine
        connected.value = .connecting
        
        return Promise { [unowned self] (fulfill, reject) in
            self.connected.producer
                .on(started: {
                    self.socket.connect()
                })
                .on(value: { (value) in
                    switch value {
                    case .connected: fulfill(true)
                    case .disconnected(let err):
                        let error = err != nil ? err! : NSError(domain: "com.jibo.rom", code: -1001, userInfo: [NSLocalizedDescriptionKey:"failed to start"])
                        reject(error)
                    case .connecting: break
                    default: break
                    }
                })
                .take(while: { (s) -> Bool in
                    return s == .connecting
                })
                .start()
        }
    }

    // Async method, tries to stop connection and returns 'isDisconnected' flag
    func stop() -> Promise<Bool>  {
        guard socket.isConnected else { return Promise(value: true) }

        // state machine
        connected.value = .disconnecting
        
        return Promise { [unowned self] (fulfill, reject) in
            self.connected.producer
                .on(started: {
                    self.socket.disconnect()
                })
                .on(value: { (value) in
                    switch value {
                    case .disconnecting: break
                    case .disconnected: fulfill(true)
                    default: reject(NSError(domain: "com.jibo.rom",code: -1002, userInfo: [NSLocalizedDescriptionKey:"failed to stop"]))
                    }
                })
                .take(while: { (s) -> Bool in
                    return s == .disconnecting
                })
                .start()
        }
    }

    func sendRequest<T: Mappable>(_ request: T) {
        if let message = request.toJSONString(prettyPrint: true) {
            send(message)
        }
    }

    fileprivate func send(_ message: String) {
        guard socket.isConnected else { return }

        print("Send text: \(message)")
        socket.write(string: message)
    }
}

