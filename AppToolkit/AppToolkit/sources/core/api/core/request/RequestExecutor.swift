//
//  RequestExecutor.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/19/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire
import ObjectMapper
import Result
import AlamofireObjectMapper

// MARK: - RequestExecutor
class RequestExecutor {
	
	let manager: SessionManager
	
	init(manager: SessionManager) {
		self.manager = manager
	}
	
	@discardableResult
    func execute(request: URLRequest,
                 authorizer: RequestAuthorizer? = nil,
                 completion: @escaping (ResponseResult<Response<ApiResponseBase>>) -> ()) -> DataRequest {
        if let authorizer = authorizer {
            requestHandler.registerAuthorizer(authorizer, for: request)
        }
		let validatedDataRequest = manager.request(request).validate()

        validatedDataRequest.responseObject(queue: DispatchQueue.global()) { [unowned self] (dataResponse: DataResponse<ApiResponseBase>) in
			let result = self.dataResponseResult(dataResponse: dataResponse)
			completion(result)
            defer {
                requestHandler.registerAuthorizer(nil, for: request)
            }
		}.resume()
		
		return validatedDataRequest
	}
	
	fileprivate func dataResponseResult(dataResponse: DataResponse<ApiResponseBase>) -> ResponseResult<Response<ApiResponseBase>> {
		switch dataResponse.result {
		case .failure(let error):
			let errorResponse = self.failureErrorResponse(from: dataResponse, error: error)
			return ResponseResult.failure(errorResponse)
		case .success(let value):
			let response = Response(dataResponse.response!, body: value)
			return ResponseResult.success(response)
		}
	}
	
	fileprivate func failureErrorResponse(from response: DataResponse<ApiResponseBase>, error: Error) -> ErrorResponse {
		let statusCode = self.failureStatusCode(from: response)
		let errorResponse = ErrorResponse(statusCode: statusCode, body: response.data, error: error)
		
		return errorResponse
	}
	
	func failureStatusCode<T>(from response: DataResponse<T>) -> Int {
		return response.response?.statusCode ?? 500
	}
}


