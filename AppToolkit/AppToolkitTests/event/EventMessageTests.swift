//
//  EventMessageTests.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

class EventMessageTests: XCTestCase {
    var event: EventMessage!

    override func setUp() {
        super.setUp()
        event = JSONLoader().loadObject(forResource: "invalidEventMessage", ofType: "json")
    }

    func testThatEventMessageInitFailsForInvalidJSON() {
        let notEvent: EventMessage? = JSONLoader().loadObject(forResource: "acknowledgement", ofType: "json")
        XCTAssertNil(notEvent)
    }
    
    func testThatEventMessageHeaderIsMapped() {
        XCTAssertEqual(event.header?.sessionID, "12345")
        XCTAssertEqual(event.header?.robotID, "cherrio-potato-onion-toe")
        XCTAssertEqual(event.header?.transactionID, mockTransactionID)
        XCTAssertEqual(event.header?.timestamp, 987456354.24)
    }

    func testInvalidJSONReturnsNil() {
        XCTAssertNil(event.body)
    }
}
