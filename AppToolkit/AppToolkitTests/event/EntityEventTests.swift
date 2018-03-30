//
//  EntityEventTests.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
@testable import AppToolkit

class EntityEventTests: XCTestCase {
    var entityEvent: EventMessage!
    override func setUp() {
        super.setUp()
        entityEvent = JSONLoader().loadObject(forResource: "entityEvent", ofType: ".json")
    }

    func testThatEventMessageConstructsEntityEvent() {
        XCTAssertTrue(entityEvent.body is EntityEvent)
    }

    func testThatTakePhotoEventBodyIsMapped() {
        guard let body = entityEvent.body as? EntityEvent else {
            XCTFail("EventBody is not of type EntityEvent")
            return
        }

        XCTAssertEqual(body.tracks.count, 1)
        XCTAssertEqual(body.tracks[0].type, .person)
        XCTAssertEqual(body.tracks[0].entityId, 12345)
        XCTAssertEqual(body.tracks[0].confidence, 1)
        XCTAssertEqual(body.tracks[0].worldCoords, Vector3(x: 0, y: 1, z: 2))
        XCTAssertEqual(body.tracks[0].screenCoords, ScreenRectangle(x: 0, y: 1, width: 2, height: 3))
    }
}
