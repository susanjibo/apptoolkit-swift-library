//
//  AcknowledgementTests.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
@testable import AppToolkit

class AcknowledgementTests: XCTestCase {
    var ack: Acknowledgement!

    override func setUp() {
        super.setUp()
        ack = JSONLoader().loadObject(forResource: "acknowledgement", ofType: "json")
    }

    func testThatAcknowledgementInitFailsForInvalidJSON() {
        let notAck: Acknowledgement? = JSONLoader().loadObject(forResource: "eventMessage", ofType: "json")
        XCTAssertNil(notAck)
    }

    func testThatAcknowledgementHeaderIsMapped() {
        XCTAssertEqual(ack.header?.sessionID, "12345")
        XCTAssertEqual(ack.header?.robotID, "cherrio-potato-onion-toe")
        XCTAssertEqual(ack.header?.transactionID, mockTransactionID)
    }

    func testThatAcknowledgementBodyIsMapped() {
        XCTAssertEqual(ack.body?.value, "Success")
        XCTAssertEqual(ack.body?.responseCode, .accepted)
        XCTAssertEqual(ack.body?.responseString, "Accepted")
    }
}
