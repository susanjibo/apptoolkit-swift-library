//
//  StartSessionResponse.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

typealias JSON = [String: AnyObject]

protocol SessionInfoProtocol: Mappable {
    var sessionId: String? { get set }
    var version: String? { get set }
}

class SessionInfo: ModelObject, SessionInfoProtocol {
    var sessionId: String?
    var version: String?
    
    override public func mapping(map: Map) {
        sessionId   <- map["SessionID"]
        version     <- map["Version"]
    }
}

class StartSessionResponse: AcknowledgementBody {
    var sessionInfo: SessionInfoProtocol?

    override public func mapping(map: Map) {
        super.mapping(map: map)
        
        sessionInfo <- (map["ResponseBody"], BasicProtocolTypeSerializationTransform<SessionInfo, SessionInfoProtocol>())
    }
}
