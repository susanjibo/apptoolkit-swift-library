//
//  VideoReadyEventTests.swift
//  AppToolkitTests
//
//  Created by JustinShiiba on 9/21/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

class VideoReadyEventTests: XCTestCase {
    var videoEvent: EventMessage!

    override func setUp() {
        super.setUp()
        videoEvent = JSONLoader().loadObject(forResource: "videoEvent", ofType: "json")
    }

    func testThatEventMessageConstructsVideoEvent() {
        XCTAssertTrue(videoEvent.body is VideoReadyEvent)
    }

    func testThatVideoEventBodyIsMapped() {
        guard let body = videoEvent.body as? VideoReadyEvent else {
            XCTFail("EventBody is not of type VideoReadyEvent")
            return
        }
        XCTAssertEqual(body.event, .videoReady)
        XCTAssertEqual(body.uri, "uri_string")
    }
}
