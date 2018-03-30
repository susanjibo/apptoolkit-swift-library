//
//  AsyncEvent.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

final class AsyncStatusEvent: BaseEvent {}


final class EventError: BaseEvent, Error {
    var errorCode: Int?
    var errorString: String?

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        errorCode   <- map["ErrorCode"]
        errorString <- map["ErrorString"]
    }
}

final class AsyncErrorEvent: BaseEvent {
    var eventError: EventError?

    override func mapping(map: Map) {
        super.mapping(map: map)
        eventError <- map["EventError"]
    }
}
