//
//  RobotService.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/24/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire
import ObjectMapper

protocol RobotServiceProtocol: Service {
	
	func obtainRobotsList(authorizer: RequestAuthorizer, completion: CommandLibraryInterface.RobotListClosure?) -> URLRequest?
	func robotsListRequest() -> URLRequest?
	
}

final class RobotsService: RobotServiceProtocol {
	
	let executor: RequestExecutor
	
	required init(executor: RequestExecutor) {
		self.executor = executor
	}
	
}

extension RobotsService {
	
	@discardableResult
	func obtainRobotsList(authorizer: RequestAuthorizer, completion: CommandLibraryInterface.RobotListClosure? = nil) -> URLRequest? {
		guard let request = self.robotsListRequest() else {
			completion?(nil, ErrorResponse(ApiError.badRequest))
			return nil
		}
		executor.execute(request: request, authorizer: authorizer) { result in
			switch result {
			case .failure(let errorResponse):
				completion?(nil, errorResponse)
			case .success(let response):
                if let apiResponse = response.body as? ApiCallResponse,
                    let robots = apiResponse.dataArray?.flatMap({ $0 as? RobotInfo}) {
                    completion?(robots, nil)
                } else {
                    completion?(nil, nil)
                }
			}
		}
		
		return request
	}
	
	/// RobotsListRequest
	func robotsListRequest() -> URLRequest? {
		let robotsList = self.robotsListFactory()
		
		let robotsListRequest = RequestBuilder()
			.urlString(robotsList.path)
			.httpMethod(robotsList.method)
			.build()
		
		return robotsListRequest.request
	}
	
	func robotsListFactory() -> RobotsParamsFactory {
		return RobotsParamsFactory.robotsList
	}
}
