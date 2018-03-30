//
//  RobotsRouter.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/18/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire

enum RobotsParamsFactory: RequestParamsFactory {
	case robotsList
	
	var path: String? {
		return EnvironmentSwitcher.shared().currentConfiguration.robotsListUrl
	}
	
	var method: HTTPMethod {
		switch self {
		case .robotsList:
			return .get
		}
	}
	
	var requestParams: RequestParamsConvertable {
		switch self {
		case .robotsList:
			return RobotListParams()
		}
	}
}

struct RobotListParams: RequestParamsConvertable {
	
	func asRequestParams() -> RequestParams {
		return [String: Any]()
	}
}
