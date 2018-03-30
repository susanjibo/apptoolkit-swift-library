//
//  CommandTests.swift
//  AppToolkitTests
//
//  Created by Alex Zablotskiy on 11/7/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

typealias JSON = [String: Any]

class CommandTests: XCTestCase {
	
	lazy var jsonLoader = JSONLoader()
	
	func isCommandConvertedSuccessfully(command: Command?, toJson json: JSON?) -> Bool {
		guard let command = command else {
			XCTFail("Command from convenience init cannot be nil")
			return false
		}
		
		guard let loadedJson = json else {
			XCTFail("Command loaded json cannot be nil")
			return false
		}
		
		return self.isAnyHashableAnyEquals(lhs: command.toJSON(), rhs: loadedJson)
	}
	
	// TODO: Move to helper
	func isAnyHashableAnyEquals(lhs: [AnyHashable: Any], rhs: [AnyHashable: Any] ) -> Bool {
		return NSDictionary(dictionary: lhs).isEqual(to: rhs)
	}
	
}
