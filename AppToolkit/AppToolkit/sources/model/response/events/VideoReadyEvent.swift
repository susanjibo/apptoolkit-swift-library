//
//  VideoReadyEvent.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

final class VideoReadyEvent: BaseEvent {
    public var uri: String = ""

    override public func mapping(map: Map) {
        super.mapping(map: map)
        uri <- map["URI"]
    }
}
