//
//  RequestHeader.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 9/29/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 :nodoc:
 */
class RequestHeader: ModelObject {
    /** 
     The reverse domain assigned name for the application provided by 
     Jibo, Inc. to the application developer.
     */
    public var appId: String?
    /**
     The session identifier that was assigned for this connection between 
     the Server and Controller. Is only allowed to be null for a `StartSession` command.
     */
    public var sessionId: String?
    public var credentials: AnyObject?
    /**
     Version that is required on the robot in order to handle the request. 
     Requesting a Protocol version that is greater than the supported version on the Robot is an error.
    */
    public var version: String?
    /** 
     See `TransactionID`
     */
    public var transactionId: String?

    /**
    :nodoc:
    */
    override public func mapping(map: Map) {
        map.shouldIncludeNilValues = true

        appId           <- map["AppID"]
        sessionId       <- map["SessionID"]
        credentials     <- map["Credentials"]
        version         <- map["Version"]
        transactionId   <- map["TransactionID"]
    }
}
