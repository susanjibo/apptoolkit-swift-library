//
//  JsonValidationTests.swift
//  AppToolkitTests
//
//  Created by Vasily Kolosovsky on 11/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import VVJSONSchemaValidation
import XCTest
import PromiseKit
import ObjectMapper
@testable import AppToolkit

//MARK: - Validator
class JsonValidator {
    var schema: VVJSONSchema?
    var storage: VVJSONSchemaStorage?
    
    init() {
        if let draft4Url = URL(string:"http://json-schema.org/draft-04/schema#"),
            let draf4Data = try? Data(contentsOf: draft4Url, options: .alwaysMapped),
            let commandSchemaData = loadSchema("commandSchema"),
            let draft4Schema = try? VVJSONSchema(data: draf4Data, baseURI: draft4Url, referenceStorage: nil),
            let storage = VVJSONSchemaStorage(schema: draft4Schema),
            let schema = try? VVJSONSchema(data: commandSchemaData, baseURI: nil, referenceStorage: storage) {
            self.storage = storage
            self.schema = schema
        }
    }

    private func loadSchema(_ name: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: name, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) else {
                return nil
        }
        return data
    }

    func validate(data: Data) -> Bool {
        do {
            try schema?.validateObject(with: data)
            return true
        } catch let validationError as NSError {
            print("validation failed: \(validationError)")
            return false
        }
    }

    func validate(json: [String: Any]) -> Bool {
        do {
            try schema?.validate(json)
            return true
        } catch let validationError as NSError {
            print("validation failed: \(validationError)")
            return false
        }
    }

}

class ValidationRequester: Requester {
    var firstRequestDidSend: Bool = false
    
    override func getSessionId() -> String? {
        guard firstRequestDidSend else {
            firstRequestDidSend = true
            return nil
        }
        return mockSessionID
    }
}

//MARK: - Tests
class JSONValidationTests: XCTestCase {
    var validator: JsonValidator!
    var requester: Requester!
    var request: Mappable?
    var mockConnection: MockConnection!
    var didSendRequestExpectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        
        request = nil
        validator = JsonValidator()
        mockConnection = MockConnection()
        mockConnection.onRequest = { [unowned self] (r) in
            self.request = r
            self.didSendRequestExpectation.fulfill()
            print("fulfill expectation")
        }
        let manager = ConnectionManager(connection: mockConnection)
        requester = ValidationRequester(connectionManager: manager, robotName: "ImmaLittleTeapot")
        print("set expectation")
        didSendRequestExpectation = self.expectation(description: "Request is sent")
    }
    
    func testGetConfig() {
        mockConnection.started = true
        _ = requester.getConfig(nil)

        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send connect request")
        }
    }
    
    func testSetConfig() {
        mockConnection.started = true
        let options = SetConfigOptions()
        options?.mixer = 0.5
        _ = requester.setConfig(options!, callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send connect request")
        }
    }

    func testConnect() {
        mockConnection.started = true
        _ = requester.connect()
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send connect request")
        }
    }

    
    func testVideoNormal() {
        sendVideoRequest(type: .normal)
    }

    func testVideoDebug() {
        sendVideoRequest(type: .debug)
    }

    func testPhotoLeftHigh() {
        sendPhotoRequest(camera: .left, resolution: .high, distortion: true)
    }

    func testPhotoLeftMed() {
        sendPhotoRequest(camera: .left, resolution: .medium, distortion: true)
    }

    func testPhotoLeftLow() {
        sendPhotoRequest(camera: .left, resolution: .low, distortion: true)
    }

    func testPhotoLeftDistortion() {
        sendPhotoRequest(camera: .left, resolution: .low, distortion: false)
    }

    func testPhotoRightHigh() {
        sendPhotoRequest(camera: .right, resolution: .high, distortion: true)
    }

    func testPhotoRightMed() {
        sendPhotoRequest(camera: .right, resolution: .medium, distortion: true)
    }
    
    func testPhotoRightLow() {
        sendPhotoRequest(camera: .right, resolution: .low, distortion: true)
    }

    func testPhotoRightDistortion() {
        sendPhotoRequest(camera: .right, resolution: .low, distortion: false)
    }

    func testLookAtPositionTrackHead() {
        sendLookAtRequest(targetType: .position(position: Vector3.default), trackFlag: true, levelHeadFlag: true)
    }

    func testLookAtPositionDoNotTrackHead() {
        sendLookAtRequest(targetType: .position(position: Vector3.default), trackFlag: false, levelHeadFlag: false)
    }

    func testLookAtAngleTrackHead() {
        sendLookAtRequest(targetType: .angle(angle: AngleVector.default), trackFlag: true, levelHeadFlag: false)
    }

    func testLookAtAngleDoNotTrackHead() {
        sendLookAtRequest(targetType: .angle(angle: AngleVector.default), trackFlag: false, levelHeadFlag: false)
    }

    func testLookAtCoordsTrackHead() {
        sendLookAtRequest(targetType: .screenCoords(screenCoords: Vector2.default), trackFlag: true, levelHeadFlag: false)
    }
    
    func testLookAtCoordsDoNotTrackHead() {
        sendLookAtRequest(targetType: .screenCoords(screenCoords: Vector2.default), trackFlag: false, levelHeadFlag: false)
    }

    func testLookAtEntityTrackHead() {
        sendLookAtRequest(targetType: .entity(entity: 1), trackFlag: true, levelHeadFlag: false)
    }
    
    func testLookAtEntityDoNotTrackHead() {
        sendLookAtRequest(targetType: .entity(entity: 1), trackFlag: false, levelHeadFlag: false)
    }

    func testSay() {
        mockConnection.started = true
        _ = requester.say(phrase: "Hey Jibo", callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send say request")
        }
    }

    func testEntity() {
        mockConnection.started = true
        _ = requester.entityRequest(callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send entity request")
        }
    }

    func testCancel() {
        mockConnection.started = true
        _ = requester.cancel(transactionId: mockTransactionID)

        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send cancel request")
        }
    }

    func testDisplayEye() {
        mockConnection.started = true
        _ = requester.displayEye(in: "testView", callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send display eye request")
        }
    }
    
    func testDisplayText() {
        mockConnection.started = true
        _ = requester.displayText("testText", in: "testView", callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send display text request")
        }
    }

    func testDisplayImage() {
        mockConnection.started = true
        _ = requester.displayImage(ImageData("testName", source: "testSource"), in: "testView", callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send display image request")
        }
    }

    func testDisplayImageWithinSet() {
        mockConnection.started = true
        _ = requester.displayImage(ImageData("testName", source: "testSource", set: "testSet"), in: "testView", callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send display image within set request")
        }
    }
    
    func testGetMotion() {
        mockConnection.started = true
        _ = requester.getMotion(callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send motion request")
        }
    }

    func testListenForSpeech() {
        mockConnection.started = true
        _ = requester.listenForSpeech(maxSpeechTimeOut: 15, maxNoSpeechTimeout: 15, languageCode: LangCode.enUS, callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send listen for speech request")
        }
    }
    
    func testListenForHeadTouch() {
        mockConnection.started = true
        _ = requester.listenForHeadTouch(callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send listen for head touch request")
        }
    }
    
    func testFetchAsset() {
        mockConnection.started = true
        _ = requester.fetchAssetWithURI("http://someurl.com/somesound.wav", name: "somesound", callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send fetch asset request")
        }
    }

    func testListenForScreenGesture() {
        let types: [ScreenGestureType] = [.tap, .swipeDown, .swipeUp, .swipeRight, .swipeLeft]
        let areas: [Area] = [Rectangle.default, Circle.default]
        didSendRequestExpectation.expectedFulfillmentCount = UInt(types.count * areas.count)
        mockConnection.started = true

        for type: ScreenGestureType in types {
            for area: Area in areas {
                let filter = ScreenGestureListenParams(type: type, area: area)
                _ = requester.listenForScreenGesture(filter, callback: nil)
                print("type: \(type), area: \(area)")
                XCTAssertNotNil(request)
                if let request = request {
                    XCTAssertTrue(validator.validate(json: request.toJSON()))
                } else {
                    XCTFail("Failed to send screen gesture request")
                }
            }
        }
        wait(for: [didSendRequestExpectation], timeout: 3.0)
    }

}

extension JSONValidationTests {
    
    fileprivate func sendVideoRequest(type: VideoType) {
        mockConnection.started = true
        _ = requester.takeVideo(videoType: type, duration: 1.0, callback: nil, finalizer: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send video request")
        }
    }
    
    fileprivate func sendPhotoRequest(camera: Camera, resolution: CameraResolution, distortion: Bool) {
        mockConnection.started = true
        _ = requester.takePhoto(with: camera, resolution: resolution, distortion: distortion, callback: nil, finalizer: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send photo request")
        }
    }

    fileprivate func sendLookAtRequest(targetType: LookAtTargetType, trackFlag: Bool, levelHeadFlag: Bool) {
        mockConnection.started = true
        _ = requester.lookAt(targetType: targetType, trackFlag: trackFlag, levelHeadFlag: trackFlag, callback: nil)
        
        wait(for: [didSendRequestExpectation], timeout: 0.3)
        XCTAssertNotNil(request)
        if let request = request {
            XCTAssertTrue(validator.validate(json: request.toJSON()))
        } else {
            XCTFail("Failed to send lookAt request")
        }
    }

}
