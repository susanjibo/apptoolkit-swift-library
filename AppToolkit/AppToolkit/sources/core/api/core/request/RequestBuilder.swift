//
//  RequestBuilder.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/23/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire

// MARK: - RequestBuilder
class RequestBuilder {
	private var credential: URLCredential?
	private var headers: [String: String] = [:]
	private var parameters: [String: Any]?
	private var method: HTTPMethod = .get
	private var urlString: String?
	private var body: [String: Any]?
	
	private var isBody: Bool {
		return body != nil
	}
	
	func addHeaders(_ headers: [String: String]) -> Self {
		for (header, value) in headers {
			self.headers[header] = value
		}
		return self
	}
	
	func addParams(_ params: [String: Any]) -> Self {
		if (parameters == nil) {
			parameters = [:]
		}
		for (key, value) in params {
			if (parameters![key] == nil) {
				parameters![key] = value
			}
		}
		return self
	}
	
	func httpMethod(_ httpMethod: HTTPMethod) -> Self {
		self.method = httpMethod
		return self
	}
	
	func addHeader(name: String, value: String) -> Self {
		if !value.isEmpty {
			headers[name] = value
		}
		return self
	}
	
	func urlString(_ urlString: String?) -> Self {
		self.urlString = urlString
		return self
	}
	
	func addBody(_ body: [String: Any]?) -> Self {
		self.body = body
		return self
	}
	
	// TODO: implement
	func addCredential() -> Self {
		return self
	}
	
	func build(with manager: SessionManager = defaultManager) -> DataRequest {
		let encoding: ParameterEncoding = isBody ? JSONEncoding() : URLEncoding()
        let params = isBody ? body! : parameters
		let path = urlString ?? "" // TODO: ??
		
		return manager.request(path, method: method, parameters: params, encoding: encoding, headers : headers)
	}
	
}
