//
//  LookAtCommandTests.swift
//  AppToolkitTests
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

class LookAtCommandTests: CommandTests {
	
	func testLookAtCommandsNotNil() {
		XCTAssertNotNil(self.lookAtPostionCommand(), "LookAtPosition command should not be nil")
		XCTAssertNotNil(self.lookAtAngleCommand, "LookAtAngle command should not be nil")
		XCTAssertNotNil(self.lookAtScreenCoordsCoommand(), "LookAtScreenCoords command should not be nil")
		XCTAssertNotNil(self.lookAtEntityCommand(), "LookAtEntity command should not be nil")
	}
	
	func testLookAtPositionCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.lookAtPostionCommand(),
		                                                           toJson: self.loadLookAtPositionJson())
		XCTAssertTrue(comparisonResult,
		              "LookAtPosition command loaded and converted JSON should equal")
	}
	
	func testLookAtAngleCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.lookAtAngleCommand(),
		                                                           toJson: self.loadLookAtAngleJson())
		XCTAssertTrue(comparisonResult,
		             "LookAtAngle command loaded and converted JSON should equal")
	}
	
	func testLookAtScreenCoordsCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.lookAtScreenCoordsCoommand(),
		                                                           toJson: self.loadLookAtScreenCoordsJson())
		XCTAssertTrue(comparisonResult,
		              "LookAtScreenCoords command loaded and converted JSON should equal")
	}
	
	func testLookAtEntityCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.lookAtEntityCommand(),
		                                                           toJson: self.loadLookAtEntityJson())
		XCTAssertTrue(comparisonResult,
		              "LookAtEntity command loaded and converted JSON should equal")
	}
	
}

// MARK: Commands
extension LookAtCommandTests {

	func lookAtPostionCommand() -> LookAtCommand? {
		let vector3 = Vector3(x: 1, y: 2, z: 3)
		return LookAtCommandsFactory.makeLookAtCommand(position: vector3)
	}
	
	func lookAtAngleCommand() -> LookAtCommand? {
		let angle = AngleVector(theta: 1, psi: 2)
		return LookAtCommandsFactory.makeLookAtCommand(angle: angle)
	}
	
	func lookAtScreenCoordsCoommand() -> LookAtCommand? {
		let screenCoords = Vector2(x: 1, y: 2)
		return LookAtCommandsFactory.makeLookAtCommand(screenCoords: screenCoords)
	}
	
	func lookAtEntityCommand() -> LookAtCommand? {
		let entity = 1
		return LookAtCommandsFactory.makeLookAtCommand(entity: entity)
	}
}

// MARK: Jsons
extension LookAtCommandTests {
	
	func loadLookAtPositionJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .lookAtPosition)
	}
	
	func loadLookAtAngleJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .lookAtAngle)
	}
	
	func loadLookAtScreenCoordsJson() ->JSON? {
		return jsonLoader.loadJson(forResource: .lookAtScreenCoords)
	}
	
	func loadLookAtEntityJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .lookAtEntity)
	}
	
}

// MARK: LookAtCommandsFactory
class LookAtCommandsFactory {
	static func makeLookAtCommand(position: Vector3,
	                              trackFlag: Bool = true,
	                              levelHeadFlag: Bool = true) -> LookAtCommand? {
		let lookAtTargetType = LookAtTargetType.position(position: position)
		return LookAtCommand(lookAtTargetType: lookAtTargetType,
		                     trackFlag: trackFlag,
		                     levelHeadFlag: levelHeadFlag)
	}
	
	static func makeLookAtCommand(angle: AngleVector,
	                              trackFlag: Bool = true,
	                              levelHeadFlag: Bool = true) -> LookAtCommand? {
		let lookAtTargetType = LookAtTargetType.angle(angle: angle)
		return LookAtCommand(lookAtTargetType: lookAtTargetType,
		                     trackFlag: trackFlag,
		                     levelHeadFlag: levelHeadFlag)
	}
	
	static func makeLookAtCommand(screenCoords: Vector2,
	                              trackFlag: Bool = true,
	                              levelHeadFlag: Bool = true) -> LookAtCommand? {
		let lookAtTargetType = LookAtTargetType.screenCoords(screenCoords: screenCoords)
		return LookAtCommand(lookAtTargetType: lookAtTargetType,
		                     trackFlag: trackFlag,
		                     levelHeadFlag: levelHeadFlag)
	}
	
	static func makeLookAtCommand(entity: LookAtEntity,
	                              trackFlag: Bool = true,
	                              levelHeadFlag: Bool = true) -> LookAtCommand? {
		let lookAtTargetType = LookAtTargetType.entity(entity: entity)
		return LookAtCommand(lookAtTargetType: lookAtTargetType,
		                     trackFlag: trackFlag,
		                     levelHeadFlag: levelHeadFlag)
	}
}
