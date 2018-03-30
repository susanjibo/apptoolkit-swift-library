//
//  CancelCommandTests.swift
//  AppToolkitTests
//
//  Created by Alex Zablotskiy on 11/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

class CancelCommandTests: CommandTests {
	
	func testCancelCommandNotNil() {
		XCTAssertNotNil(self.cancelCommand(), "Cancel command should not be nil")
	}
	
	func testCancelCommandConvertedToJson() {
		let comparisonResult = self.isCommandConvertedSuccessfully(command: self.cancelCommand(),
		                                                           toJson: self.loadCancelCommandJson())
		
		XCTAssertTrue(comparisonResult, "Loaded and converted Cancel command json should equal")
	}
	
}

extension CancelCommandTests {
	
	fileprivate func cancelCommand() -> CancelCommand? {
		return CancelCommand(transactionId: "abc12325765fb1a26ee0c422aefaa99a")
	}
	
	fileprivate func loadCancelCommandJson() -> JSON? {
		return jsonLoader.loadJson(forResource: .cancelCommand)
	}
	
}
