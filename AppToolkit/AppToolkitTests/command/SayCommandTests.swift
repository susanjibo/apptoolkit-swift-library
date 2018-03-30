//
//  SayCommandTests.swift
//  JiboRomSdkTests
//
//  Created by Alex Zablotskiy on 11/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import JiboRomSdk

class SayCommandTests: CommandTests {
	
	func testSayCommandNotNil() {
		XCTAssertNotNil(self.sayCommand(), "Cancel command should not be nil")
	}
	
	func testCancelCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.sayCommand(),
		                                                           toJson: self.loadSayCommandJson())
		
		XCTAssertTrue(comparisonResult, "Loaded and converted Say command json should equal")
	}
	
}

extension SayCommandTests {
	
	fileprivate func sayCommand() -> SayCommand? {
		return SayCommand(phrase: "Here is my handle here is my spout")
	}
	
	fileprivate func loadSayCommandJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .sayCommand)
	}
}
