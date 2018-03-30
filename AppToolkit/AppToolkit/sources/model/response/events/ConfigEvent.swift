//
//  ConfigEvent.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/12/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class ConfigEvent: BaseEvent {
    var battery: Battery?
    var wifi: WiFi?
    var position: Position?
    var mixers: Mixers?
    
    override func mapping(map: Map) {
        battery  <- map["Battery"]
        wifi     <- map["Wifi"]
        position <- map["Position"]
        mixers   <- map["Mixers"]
    }

}
