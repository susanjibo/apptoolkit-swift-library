//
//  RequestHandler.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/23/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire

fileprivate struct Refresher {
	var isRefreshing = false
}

// MARK: - RequestHandler
final class RequestHandler: RequestAdapter, RequestRetrier {
	fileprivate typealias RefreshCompletion = (_ succeeded: Bool) -> ()
	fileprivate lazy var oauthService = OAuthService(executor: requestExecutor)
	
	fileprivate var refresher = Refresher()
	
	fileprivate var authorizers: [URL: RequestAuthorizer] = [:]
	
	func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
		if let url = urlRequest.url, let authorizer = authorizers[url] {
			return authorizer.authorize(request: urlRequest)
		}
		return urlRequest
	}
	
	func should(_ manager: Alamofire.SessionManager,
	            retry request: Alamofire.Request,
	            with error: Error,
	            completion: @escaping Alamofire.RequestRetryCompletion) {
		
		if let response = request.task?.response as? HTTPURLResponse,
			response.statusCode == 401 {
            guard let _ = KeychainUtils.obtainOrRemoveTokenIfNotValid() else {
                completion(false, 0.0)
                return
            }
            
            defer {
                KeychainUtils.removeToken()
                KeychainUtils.removeCertificates()
            }
            print("Invalid token, trying to refresh...")
            completion(true, retryDelay(for: response))

            if let url = request.request?.url {
                refreshTokens(for: url, completion: {_ in })
            }
		} else {
			completion(false, 0.0)
		}
	}
	
	func registerAuthorizer(_ authorizer: RequestAuthorizer?, for urlRequest: URLRequestConvertible) {
		do {
			let urlRequest = try urlRequest.asURLRequest()
			if let url = urlRequest.url {
				authorizers[url] = authorizer
			}
		} catch {
		}
	}
}

// MARK: - Private
extension RequestHandler {
	// MARK: - Refresh Tokens
    fileprivate func refreshTokens(for url: URL, completion: @escaping RefreshCompletion) {
		guard !refresher.isRefreshing,
			let clientInfo = ClientInfo.makeInfo() else {
                completion(false)
                return
        }
		
		refresher.isRefreshing = true
		
		oauthService.refreshToken(clientInfo: clientInfo) { [weak self] result in
			guard let sself = self else {
                completion(false)
                return
            }
			
			switch result {
            case (.failure(let error), _):
                print("RefreshToken failed: \(error.localizedDescription)")
				completion(false)
            case (.success(let success), let token):
                print("RefreshToken succeed")
                if let authorizer = sself.authorizers[url] {
                    authorizer.updateToken(token: token)
                }
				completion(success)
			}
			sself.refresher.isRefreshing = false
		}
	}
	
	// MARK: - Refresh delay
	fileprivate func retryDelay(for response: HTTPURLResponse) -> TimeInterval {
		guard let retryAfter = response.allHeaderFields["retry-after"] as? String else { return 15.0 }
		return TimeInterval(retryAfter) ?? 15
	}
}
