//
//  TakePhotoTests.swift
//  AppToolkitTests
//
//  Created by Alex Zablotskiy on 11/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

class TakePhotoTests: CommandTests {
	
	func testTakePhotoCommandNotNil() {
		XCTAssertNotNil(self.takePhotoHighResCommand(), "TakePhoto High Resolution command should not be nil")
		XCTAssertNotNil(self.takePhotoMediumResCommand(), "TakePhoto Medium Resolution command should not be nil")
		XCTAssertNotNil(self.takePhotoLowResCommand(), "TakePhoto Low Resolution command should not be nil")
		XCTAssertNotNil(self.takePhotoMicroResCommand(), "TakePhoto Micro Resolution command should not be nil")
		
		XCTAssertNotNil(self.takePhotoLeftCameraDistortionCommand(), "TakePhoto Left Camera command should not be nil")
		
	}

	func testTakePhotoHighResConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.takePhotoHighResCommand(),
		                                                           toJson: self.loadPhotoHighResolutionJson())
		XCTAssertTrue(comparisonResult, "High resolution loaded and converted Photo command json should equal")
	}
	
	func testTakePhotoMediumResConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.takePhotoMediumResCommand(),
		                                                           toJson: self.loadPhotoMediumResolutionJson())
		
		XCTAssertTrue(comparisonResult, "Medium resolution loaded and converted Photo command json should equal")
	}
	
	func testTakePhotoLowResConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.takePhotoLowResCommand(),
		                                                           toJson: self.loadPhotoLowResolutionJson())
		
		XCTAssertTrue(comparisonResult, "Low resolution loaded and converted Photo command json should equal")
	}
	
	func testTakePhotoMicroResConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.takePhotoMicroResCommand(),
		                                                           toJson: self.loadPhotoMicroResolutionJson())
		
		XCTAssertTrue(comparisonResult, "Micro resolution loaded and converted Photo command json should equal")
	}
	
	func testTakePhotoLeftCameraWithDistortionConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.takePhotoLeftCameraDistortionCommand(),
		                                                           toJson: self.loadPhotoLeftCameraDistortionJson())
		
		XCTAssertTrue(comparisonResult, "Left camera with distortion loaded and converted Photo command json should equal")
	}
}

extension TakePhotoTests {
	// High Resoultoin
	fileprivate func takePhotoHighResCommand() -> TakePhotoCommand? {
		return TakePhotoCommand(camera: .right, resolution: .high, distortion: false)
	}
	
	fileprivate func loadPhotoHighResolutionJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .takePhotoHighRes)
	}
	
	// Medium Resolution
	fileprivate func takePhotoMediumResCommand() -> TakePhotoCommand? {
		return TakePhotoCommand(camera: .right, resolution: .medium, distortion: false)
	}
	
	fileprivate func loadPhotoMediumResolutionJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .takePhotoMediumRes)
	}
	
	// Low Resoultion
	fileprivate func takePhotoLowResCommand() -> TakePhotoCommand? {
		return TakePhotoCommand(camera: .right, resolution: .low, distortion: false)
	}
	
	fileprivate func loadPhotoLowResolutionJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .takePhotoLowRes)
	}
	
	// Micro Resolution
	fileprivate func takePhotoMicroResCommand() -> TakePhotoCommand? {
		return TakePhotoCommand(camera: .right, resolution: .micro, distortion: false)
	}
	
	fileprivate func loadPhotoMicroResolutionJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .takePhotoMicroRes)
	}
	
	// LeftCamera and Distortion
	fileprivate func takePhotoLeftCameraDistortionCommand() -> TakePhotoCommand? {
		return TakePhotoCommand(camera: .left, resolution: .medium, distortion: true)
	}
	
	fileprivate func loadPhotoLeftCameraDistortionJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .takePhotoLeftCameraDistortion)
	}
}
