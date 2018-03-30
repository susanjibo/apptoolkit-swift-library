//
//  AuthCallResponse.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/25/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthCallResponse: ApiResponseBase {
    
    static func objectForMapping(map: Map) -> BaseMappable? {
        if let _: Any? = map[OAuthParams.accessToken].value(),
            let _: Any? = map[OAuthParams.refreshToken].value() {
            return Token()
        }
        return nil
    }
    
    override func isAuthCall() -> Bool {
        return false
    }
}

struct TokenConstants {
	static let tokenTTL: TimeInterval = 1.0.hourToSeconds()
}

//MARK: - Token
enum TokenType: String {
    case undefined
    case bearer = "Bearer"
    
    func asAuthParameter() -> String {
        return self.rawValue
    }
}

class Token: AuthCallResponse {
    var accessToken: String = ""
    var refreshToken: String = ""
    var type: TokenType = .undefined
	var creationDate: Date = Date()
	
	required init?(map: Map) {
		super.init(map: map)
	}
    
    convenience public required init?() {
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type            <- map[OAuthParams.tokenType]
        accessToken     <- map[OAuthParams.accessToken]
        refreshToken    <- map[OAuthParams.refreshToken]
    }
	
    func isValid() -> Bool {
        return !accessToken.isEmpty &&
            !refreshToken.isEmpty &&
            type != .undefined
    }
	
	func isTTLValid() -> Bool {
		return creationDate.isTokenTTLValid()
	}
}
