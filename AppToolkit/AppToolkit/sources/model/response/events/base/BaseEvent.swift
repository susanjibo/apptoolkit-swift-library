//
//  BaseEvent.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseEvent: ModelObject {
    var event: EventType = .undefined

    public required init?(map: Map) {
        super.init(map: map)
        event <- (map[EventID], EnumTransform<EventType>())
    }
}
