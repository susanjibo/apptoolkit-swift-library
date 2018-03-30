//
//  OAuthService.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/24/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire

protocol Service {
	var executor: RequestExecutor { get }
	
	init(executor: RequestExecutor)
}

protocol OAuthServiceProtocol: Service {
	
	func obtainToken(code: String, clientInfo: ClientInfo, completion: @escaping (Alamofire.Result<Bool>) -> ()) -> URLRequest?
    func refreshToken(clientInfo: ClientInfo, completion: @escaping (Alamofire.Result<Bool>, Token?) -> ()) -> URLRequest?

	func tokenRequest(code: String, clientInfo: ClientInfo) -> URLRequest?
	func refreshTokenRequest(clientInfo: ClientInfo, refreshToken: String) -> URLRequest?
	func loginRequestBundle(clientID: String) -> (String, URLRequest?)
}

final class OAuthService: OAuthServiceProtocol {
	
	let executor: RequestExecutor
	
	required init(executor: RequestExecutor) {
		self.executor = executor
	}
	
}

// MARK: - Token
extension OAuthService {
	
	@discardableResult
	func obtainToken(code: String,
	                 clientInfo: ClientInfo,
	                 completion: @escaping (Alamofire.Result<Bool>) -> ()) -> URLRequest? {
		
		guard let request = tokenRequest(code: code, clientInfo: clientInfo) else {
            completion(.failure(ApiError.badRequest))
			return nil
		}
		
		executor.execute(request: request) { [unowned self] result in
			let tokenResponseHandleResult = self.handleTokenRequestResult(requestResult: result)
			completion(tokenResponseHandleResult)
		}
		
		return request
	}
	
	fileprivate func handleTokenRequestResult(requestResult: ResponseResult<Response<ApiResponseBase>>) -> Alamofire.Result<Bool> {
		switch requestResult {
		case .failure(let errorResponse):
			return .failure(errorResponse.asNSError())
		case .success(let response):
			let success = self.parseAndSaveToken(from: response.body)
			return .success(success)
		}
	}
	
	fileprivate func parseAndSaveToken(from data: ApiResponseBase?) -> Bool {
        guard let data = data,
            let token = data as? Token else {
				return false
		}
        return KeychainUtils.saveTokenIfValid(token: token)
	}
	
	/// TokenRequest
	func tokenRequest(code: String, clientInfo: ClientInfo) -> URLRequest? {
		let token = self.tokenFactory(code: code, clientInfo: clientInfo)
		
		let tokenRequest = RequestBuilder()
			.addParams(token.requestParams.asRequestParams())
			.urlString(token.path)
			.httpMethod(.post)
			.build()
		
		return tokenRequest.request
	}
	
	fileprivate func tokenFactory(code: String, clientInfo: ClientInfo) -> OAuthParamsFactory {
		return OAuthParamsFactory.token(code: code, clientInfo: clientInfo)
	}
}

// MARK: RefreshToken
extension OAuthService {
	
	@discardableResult
	func refreshToken(clientInfo: ClientInfo,
                      completion: @escaping (Alamofire.Result<Bool>, Token?) -> ()) -> URLRequest? {
        guard let currentToken = KeychainUtils.obtainOrRemoveTokenIfNotValid(),
            !currentToken.refreshToken.isEmpty,
            currentToken.type != .undefined,
            let request = self.refreshTokenRequest(clientInfo: clientInfo,
                                                   refreshToken: currentToken.refreshToken) else {
                                                    completion(.failure(ApiError.tokenRefreshFailed), nil)
                                                    return nil
        }

		executor.execute(request: request) { result in
			switch result {
			case .failure(let errorResponse):
                completion(.failure(errorResponse.asNSError()), nil)
			case .success(let response):
                guard let data = response .body as? AuthCallResponse,
                    let token = data as? Token else {
                        completion(.success(false), nil)
						return
				}
                
                token.type = currentToken.type
                let success = KeychainUtils.saveTokenIfValid(token: token)
                completion(.success(success), success ? token : nil)
			}
		}
		return request
	}
	
	func refreshTokenRequest(clientInfo: ClientInfo, refreshToken: String) -> URLRequest? {
		let refreshToken = self.refreshTokenFactory(clientInfo: clientInfo, refreshToken: refreshToken)
		
		let tokenRequest = RequestBuilder()
			.addParams(refreshToken.requestParams.asRequestParams())
			.urlString(refreshToken.path)
			.httpMethod(.post)
			.build()
		
		return tokenRequest.request
	}
	
	fileprivate func refreshTokenFactory(clientInfo: ClientInfo, refreshToken: String) -> OAuthParamsFactory {
		return OAuthParamsFactory.refreshToken(clientInfo: clientInfo, refreshToken: refreshToken)
	}
}

// MARK: - Login
extension OAuthService {
	func loginRequestBundle(clientID: String) -> (String, URLRequest?) {
		let login = self.loginFactory(clientID: clientID)
		let loginParams = (login.requestParams as! LoginParams)
		let state = loginParams.state
		
		let loginRequest = RequestBuilder()
			.addParams(loginParams.asRequestParams())
			.httpMethod(login.method)
			.urlString(login.path)
			.build()
		
		return (state, loginRequest.request)
	}
	
	fileprivate func loginFactory(clientID: String) -> OAuthParamsFactory {
		return OAuthParamsFactory.login(clientID: clientID)
	}
}
