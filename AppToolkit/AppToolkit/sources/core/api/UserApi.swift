//
//  UserApi.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/18/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire

struct UserParams {
	static let id = "id"
	static let email = "email"
}

enum UserRouter {
	case userInfo
	
	var path: String? {
		switch self {
		case .userInfo:
			return EnvironmentSwitcher.shared().currentConfiguration.userInfoUrl
		}
	}
	
	var method: HTTPMethod {
		switch self {
		case .userInfo:
			return .get
		}
	}
	
	var params: [String: Any] {
		switch self {
		case .userInfo:
			return [String: Any]()
		}
	}
}
