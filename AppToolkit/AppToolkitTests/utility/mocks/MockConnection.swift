//
//  MockConnection.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/9/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper
@testable import AppToolkit

class MockConnection: Connectivity {

    var started = false
    func start() -> Promise<Bool> {
        return Promise(value: started)
    }

    var stopped = false
    func stop() -> Promise<Bool> {
        return Promise(value: stopped)
    }

    var sendRequestCalled = false
    func sendRequest<T>(_ request: T) where T : Mappable {
        sendRequestCalled = true
        onRequest?(request)
    }

    var onTextMessageCalled = false
    var onTextMessage: ((String) -> ())?

    var onDataMessageCalled = false
    var onDataMessage: ((Data) -> ())?

    var onConnectedChangeCalled = false
    var onConnectedChange: ((Bool, Error?) -> ())?

    var onRequest: ((Mappable) -> ())?
}

class MockConnectionStateChangeDelegate { //: ConnectionStateDelegate {
    var didChangeConnectionStateCalled = false
    func didChangeConnectionState(state: Bool, error: Error?) {
        didChangeConnectionStateCalled = true
    }
}

class MockConnectionEventDelegate { //: ConnectionEventMessageDelegate {
    var didReceiveEventMessageCalled = false
    func didReceiveEventMessage(_ event: EventMessage) {
        didReceiveEventMessageCalled = true
    }
}

class MockConnectionAcknowledgementDelegate { //: ConnectionAcknowledgementDelegate {
    var didReceiveAcknowledgementCalled = false
    func didReceiveAcknowledgement(_ acknowledgement: Acknowledgement) {
        didReceiveAcknowledgementCalled = true
    }
}
