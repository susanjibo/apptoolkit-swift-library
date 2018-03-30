//
//  TakePhotoEventTests.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
@testable import AppToolkit

class TakePhotoEventTests: XCTestCase {
    var takePhotoEvent: EventMessage!
    override func setUp() {
        super.setUp()
        takePhotoEvent = JSONLoader().loadObject(forResource: "takePhotoEvent", ofType: ".json")
    }

    func testThatEventMessageConstructsTakePhotoEvent() {
        XCTAssertTrue(takePhotoEvent.body is TakePhotoEvent)
    }

    func testThatTakePhotoEventBodyIsMapped() {
        guard let body = takePhotoEvent.body as? TakePhotoEvent else {
            XCTFail("EventBody is not of type TakePhotoEvent")
            return
        }

        XCTAssertEqual(body.uri, "uri_string")
        XCTAssertEqual(body.name, "name")
        XCTAssertEqual(body.positionTarget, Vector3(x: 0, y: 1, z: 2))
        XCTAssertEqual(body.angleVector, AngleVector(theta: 0, psi: 1))
    }
}
