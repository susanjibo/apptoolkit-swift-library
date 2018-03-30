//
//  TakePhotoEvent.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

final class TakePhotoEvent: BaseEvent {
    var uri: String = ""
    var name: String = ""
    var positionTarget: Vector3 = Vector3.default
    var angleVector: AngleVector = AngleVector.default

    override public func mapping(map: Map) {
        super.mapping(map: map)
        uri            <- map["URI"]
        name           <- map["Name"]
        positionTarget <- (map["PositionTarget"], Vector3Transformer())
        angleVector    <- (map["AngleTarget"], AngleVectorTransformer())
    }
}
