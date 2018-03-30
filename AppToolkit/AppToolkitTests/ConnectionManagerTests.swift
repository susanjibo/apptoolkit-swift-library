//
//  ConnectionManagerTests.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/9/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import PromiseKit
import ObjectMapper
@testable import AppToolkit

class ConnectionManagerTests: XCTestCase {
    var manager: ConnectionManager!
    var mockConnection = MockConnection()
    var mockEventDelegate = MockConnectionEventDelegate()
    var mockAckDelegate = MockConnectionAcknowledgementDelegate()
    var mockStateChangeDelegate = MockConnectionStateChangeDelegate()
    override func setUp() {
        super.setUp()
        manager = ConnectionManager(connection: mockConnection)
//        manager.connectionStateDelegate = mockStateChangeDelegate
//        manager.eventDelegate = mockEventDelegate
//        manager.acknowledgementDelegate = mockAckDelegate
    }

    func testThatSendRequestForwardsToConnection() {
        manager.sendRequest(Request<Command>()!)
        XCTAssertTrue(mockConnection.sendRequestCalled)
    }

    func testThatConnectionSucceeds() {
        mockConnection.started = true

        let expectation = self.expectation(description: "Connection Succeeds")
        _ = manager.connect().then { succeed -> () in
            if succeed {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.3)
    }

    func testThatConnectionFails() {
        mockConnection.started = false

        let expectation = self.expectation(description: "Connection Fails")
        _ = manager.connect().then { succeed -> () in
            if !succeed {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.3)
    }

    func testThatDisconnectSucceeds() {
        mockConnection.stopped = true

        let expectation = self.expectation(description: "Disconnect Succeeds")
        _ = manager.disconnect().then { succeed -> () in
            if succeed {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.3)
    }

    func testThatDisconnectFails() {
        mockConnection.stopped = false

        let expectation = self.expectation(description: "Disconnect Fails")
        _ = manager.disconnect().then { succeed -> () in
            if !succeed {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.3)
    }

    func testThatInvalidStringDoesNotNotifyDelegates() {
        mockConnection.onTextMessage?("")
        XCTAssertFalse(mockEventDelegate.didReceiveEventMessageCalled)
        XCTAssertFalse(mockAckDelegate.didReceiveAcknowledgementCalled)
    }

    func testThatEventMessageNotifiesEventDelegate() {
        let event = JSONLoader().loadJsonString(forResource: "videoEvent", ofType: "json")
        mockConnection.onTextMessage?(event ?? "")
        XCTAssertTrue(mockEventDelegate.didReceiveEventMessageCalled)
    }

    func testThatAcknowledgementNotifiesAcknowledgementDelegate() {
        let ack = JSONLoader().loadJsonString(forResource: "acknowledgement", ofType: "json")
        mockConnection.onTextMessage?(ack ?? "")
        XCTAssertTrue(mockAckDelegate.didReceiveAcknowledgementCalled)
    }

    func testThatConnectionChangeNotifiesConnectionStateDelegate() {
        mockConnection.onConnectedChange?(true, nil)
        XCTAssertTrue(mockStateChangeDelegate.didChangeConnectionStateCalled)
    }
}
