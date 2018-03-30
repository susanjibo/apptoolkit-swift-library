//
//  ResponseHeader.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 9/26/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Response Header Info
 */
class ResponseHeader: ModelObject {
    /** My-Friendly-Robot-Name */
    public var robotID: String?
    /** Session identifier that was assigned for this connection between Server and Controller */
    public var sessionID: String?
    /** See `TransactionID` */
    public var transactionID: TransactionID?
    
    /** :nodoc: */
    override public func mapping(map: Map) {
        robotID         <- map["RobotID"]
        sessionID       <- map["SessionID"]
        transactionID   <- map["TransactionID"]
    }
}
