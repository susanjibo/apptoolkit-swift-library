//
//  ViewStateEvent.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class DisplayViewStateEvent: BaseEvent {
    var state: DisplayViewState? = nil

    override func mapping(map: Map) {
        super.mapping(map: map)
        state <- map["State"]
    }
}
