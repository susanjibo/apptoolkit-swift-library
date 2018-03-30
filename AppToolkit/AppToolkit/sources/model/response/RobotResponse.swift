//
//  RobotResponse.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/10/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

internal let ResponseHeaderID = "ResponseHeader"
internal let EventHeaderID = "EventHeader"

protocol RobotResponse: StaticMappable {
    func isAcknowledgement() -> Bool
    func isEvent() -> Bool
}

extension RobotResponse {

    static func objectForMapping(map: Map) -> BaseMappable? {
        if let _: Any? = map[ResponseHeaderID].value() {
            return Acknowledgement()
        } else if let _: Any? = map[EventHeaderID].value() {
            return EventMessage()
        }

        return nil
    }

}

class ResponseBase: RobotResponse {
    func mapping(map: Map) {
    }
    
    func isAcknowledgement() -> Bool {
        return false
    }
    
    func isEvent() -> Bool {
        return false
    }
}
