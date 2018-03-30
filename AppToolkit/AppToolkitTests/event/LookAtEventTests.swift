//
//  LookAtEventTests.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
@testable import AppToolkit

class LookAtEventTests: XCTestCase {
    var lookAtEvent: EventMessage!
	
	override func setUp() {
        super.setUp()
        lookAtEvent = JSONLoader().loadObject(forResource: "lookAtAchievedEvent", ofType: ".json")
    }

    func testThatEventMessageConstructsLookAtEvent() {
        XCTAssertTrue(lookAtEvent.body is LookAtEvent)
    }

    func testThatLookAtAchievedEventBodyIsMapped() {
        guard let body = lookAtEvent.body as? LookAtEvent else {
            XCTFail("EventBody is not of type LookAtEvent")
            return
        }

        XCTAssertNil(body.entityTarget)
        XCTAssertEqual(body.angleTarget, AngleVector(theta: 0, psi: 1))
        XCTAssertEqual(body.positionTarget, Vector3(x: 0, y: 1, z: 2))
    }

    func testThatLookAtTrackLostEventBodyIsMapped() {
        lookAtEvent = JSONLoader().loadObject(forResource: "lookAtTrackLostEvent", ofType: ".json")

        guard let body = lookAtEvent.body as? LookAtEvent else {
            XCTFail("EventBody is not of type LookAtEvent")
            return
        }

        XCTAssertEqual(body.entityTarget, 1)
        XCTAssertEqual(body.angleTarget, AngleVector(theta: 0, psi: 1))
        XCTAssertEqual(body.positionTarget, Vector3(x: 0, y: 1, z: 2))
    }
}

