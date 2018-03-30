//
//  GetFaceEntityTests.swift
//  AppToolkitTests
//
//  Created by Alex Zablotskiy on 11/9/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

class GetFaceEntityTests: CommandTests {
	
	func testFaceEntityCommandNotNil() {
		XCTAssertNotNil(self.faceEntityCommand(), "Face entty command should not be nil")
	}
	
	func testFaceEntityCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.faceEntityCommand(),
		                                                           toJson: self.loadFaceEntityJson())
		XCTAssertTrue(comparisonResult, "Loaded and converted FaceEntity command json should equal")
	}
}

extension GetFaceEntityTests {
	
	fileprivate func faceEntityCommand() -> EntityRequest? {
		return EntityRequest()
	}
	
	fileprivate func loadFaceEntityJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .getFaceEntity)
	}
}
