//
//  AuthApi.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/18/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire

enum ResponseType: String {
	case code = "code"
}

enum Scope: String {
	case rom = "rom"
}

enum GrantType: String {
	case authorizationCode 	= "authorization_code"
	case refreshToken 		= "refresh_token"
}

struct OAuthParams {
	
	/// Base
	static let clientID = "client_id"
	static let clientSecret = "client_secret"
	static let redirectURI = "redirect_uri"
	
	/// Login
	static let responseType = "response_type"
	static let scope = "scope"
	static let state = "state"
	
	/// Token
	static let grantType = "grant_type"
	static let code = "code"
	static let accessToken = "access_token"
	static let refreshToken = "refresh_token"
	static let tokenType = "token_type"
	
	static let creationDate = "creation_date"
	
}

enum OAuthParamsFactory: RequestParamsFactory {
	case login(clientID: String)
	case token(code: String, clientInfo: ClientInfo)
	case refreshToken(clientInfo: ClientInfo, refreshToken: String)
	
	var path: String? {
		switch self {
		case .login:
			return EnvironmentSwitcher.shared().currentConfiguration.authUrl
		case .token,
		     .refreshToken:
			return EnvironmentSwitcher.shared().currentConfiguration.tokenUrl
		}
	}
	
	var method: HTTPMethod {
		switch self {
		case .login:
			return .get
		case .token,
		     .refreshToken:
			return .post
		}
	}
	
	var requestParams: RequestParamsConvertable {
		switch self {
		case .login(let clientID):
			return LoginParams(clientID: clientID)
		case .token(let code, let clientInfo):
			return TokenParams(code: code, clientInfo: clientInfo)
		case .refreshToken(let clientInfo, let refreshToken):
			return RefreshTokenParams(clientInfo: clientInfo, refreshToken: refreshToken)
		}
	}
}

/// Login params
struct LoginParams: RequestParamsConvertable {
	let clientID: String
	let state = Date().generateToken()
	
	func asRequestParams() -> RequestParams {
		var params = [String: Any]()
		
		params[OAuthParams.clientID] = clientID
		params[OAuthParams.responseType] = ResponseType.code.rawValue
		params[OAuthParams.scope] = Scope.rom.rawValue
		
		params[OAuthParams.state] = state
		params[OAuthParams.redirectURI] = EnvironmentSwitcher.shared().currentConfiguration.redirectURI
		
		return params
	}
}

/// Token params
struct TokenParams: RequestParamsConvertable {
	let code: String
	let clientInfo: ClientInfo
	
	func asRequestParams() -> RequestParams {
		var params = [String: Any]()

		params[OAuthParams.code] = code
		params[OAuthParams.clientID] = clientInfo.clientID
		params[OAuthParams.redirectURI] = EnvironmentSwitcher.shared().currentConfiguration.redirectURI
		params[OAuthParams.grantType] = GrantType.authorizationCode.rawValue
		if !clientInfo.clientSecret.isEmpty {
			params[OAuthParams.clientSecret] = clientInfo.clientSecret
		}

		return params
	}
}

/// RefreshToken params
struct RefreshTokenParams: RequestParamsConvertable {
	
	let clientInfo: ClientInfo
	let refreshToken: String
	
	func asRequestParams() -> RequestParams {
		var params = [String: Any]()
		
		params[OAuthParams.grantType] = GrantType.refreshToken.rawValue
		params[OAuthParams.clientID] = clientInfo.clientID
		params[OAuthParams.refreshToken] = refreshToken
		if !clientInfo.clientSecret.isEmpty {
			params[OAuthParams.clientSecret] = clientInfo.clientSecret
		}
		
		return params
	}
	
}
