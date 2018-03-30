//
//  LookAtEvent.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class LookAtEvent: BaseEvent {
	
    var positionTarget: Vector3 = Vector3.default
    var angleTarget: AngleVector = AngleVector.default
    var entityTarget: LookAtEntity?

    override func mapping(map: Map) {
        super.mapping(map: map)
        positionTarget  <- (map["PositionTarget"], Vector3Transformer())
        angleTarget     <- (map["AngleTarget"], AngleVectorTransformer())
        entityTarget    <- map["EntityTarget"]
    }
}
