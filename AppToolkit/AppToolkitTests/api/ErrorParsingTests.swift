//
//  ErrorParsingTests.swift
//  AppToolkitTests
//
//  Created by Alex Zablotskiy on 10/19/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import AppToolkit

class ErrorsObject: ModelObject {
	var message: [String]?
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		message <- map["message"]
	}
}

class ErrorParsingTests: XCTestCase {
	
	lazy var loader: JSONLoader = JSONLoader()
	
	func testErrorResponseLoaded() {
		guard let json = loadErrorResponse() else {
			XCTFail("Error response json should not be nil")
			return
		}
		print(json)
	}
	
	func loadErrorResponse() -> [String: Any]? {
		return loader.loadJson(forResource: .responseError)
	}
	
}
