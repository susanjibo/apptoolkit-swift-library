//
//  Response.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/23/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire

// MARK: - Response<T>
class Response<T> {
	let statusCode: Int
	let header: [String: String]
	var body: T?
	
	init(_ statusCode: Int, header: [String: String]) {
		self.statusCode = statusCode
		self.header = header
	}
	
	init(_ statusCode: Int, header: [String: String], body: T?) {
		self.statusCode = statusCode
		self.header = header
		self.body = body
	}
	
	convenience init(_ response: HTTPURLResponse, body: T?) {
		let rawHeader = response.allHeaderFields
		var header = [String:String]()
		for (key, value) in rawHeader {
			header[key as! String] = value as? String
		}
		self.init(response.statusCode, header: header, body: body)
	}
	
	convenience init(_ response: HTTPURLResponse) {
		let rawHeader = response.allHeaderFields
		var header = [String:String]()
		for (key, value) in rawHeader {
			header[key as! String] = value as? String
		}
		self.init(response.statusCode, header: header)
	}
}
