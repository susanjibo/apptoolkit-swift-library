//
//  ApiCore.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/23/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire
import ObjectMapper
import Result

typealias RequestParams = [String: Any]

protocol RequestParamsConvertable {
	func asRequestParams() -> RequestParams
}

protocol RequestParamsFactory {
	var path: String? { get }
	var method: HTTPMethod { get }
	var requestParams: RequestParamsConvertable { get }
}

// MARK: - Default RequestHandler
var requestHandler = {
	return RequestHandler()
}()

var requestExecutor = {
	return RequestExecutor(manager: defaultManager)
}()

// MARK: - Default SessionManager
var defaultManager: Alamofire.SessionManager = {
	let manager = Alamofire.SessionManager()
	manager.startRequestsImmediately = false
	manager.adapter = requestHandler
	manager.retrier = requestHandler
	return manager
}()

// MARK: - ResponseResult<Value>
enum ResponseResult<Value> {
	case success(Value)
	case failure(ErrorResponse)
}
