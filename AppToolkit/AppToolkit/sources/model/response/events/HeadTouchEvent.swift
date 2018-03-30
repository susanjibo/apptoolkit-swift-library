//
//  HeadTouchEvent.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class HeadTouchEvent: BaseEvent {
    var pads: [Bool]? = nil
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        pads <- map["Pads"]
    }
}
