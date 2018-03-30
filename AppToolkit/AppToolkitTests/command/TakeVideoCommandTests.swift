//
//  TakeVideoCommandTests.swift
//  AppToolkitTests
//
//  Created by Alex Zablotskiy on 11/7/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

class TakeVideoCommandTests: CommandTests {
	
	func testTakeVideoCommandNotNil() {
		XCTAssertNotNil(self.takeVideoCommand(),
		                "Video command from convenience init cannot be nil")
		XCTAssertNotNil(self.takeVideoCommandDebug(),
		                "Debug Video command from convenience init cannot be nil")
	}
	
	func testTakeVideoCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.takeVideoCommand(),
		                                                           toJson: self.loadVideoCommandJson())
		
		XCTAssertTrue(comparisonResult,
		              "TakeVideo command should be converted to loaded json example")
	}
	
	func testDebugTakeVideoCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.takeVideoCommandDebug(),
		                                                           toJson: self.loadVideoCommandDebugJson())
		
		XCTAssertTrue(comparisonResult,
		              "TakeVideo command should be converted to loaded json example")
	}
	
}
extension TakeVideoCommandTests {
	fileprivate func takeVideoCommandDebug() -> VideoCommand? {
		return VideoCommand(videoType: .debug, duration: 500)
	}
	
	fileprivate func loadVideoCommandDebugJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .takeVideoDebug)
	}
	
	fileprivate func takeVideoCommand() -> VideoCommand? {
		return VideoCommand(videoType: .normal, duration: 500)
	}
	
	fileprivate func loadVideoCommandJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .takeVideo)
	}
}
