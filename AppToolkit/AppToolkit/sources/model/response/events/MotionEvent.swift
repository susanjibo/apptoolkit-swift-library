//
//  MotionEvent.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK: Motion
/**
 Protocol for when Jibo sees motion.
 */
public protocol MotionEntityProtocol {
    /// minimum = `0`, maximum = `1`
    var intensity: Double? { get set }
    /// 3D point of the motion in space.
    var worldCoords: Vector3?  { get set }
    /// 2D coordinate of the motion detected relative to Jibo's screen.
    var screenCoords: ScreenRectangle? { get set }
}

class MotionEntity: ModelObject, MotionEntityProtocol {
    var intensity: Double?
    var worldCoords: Vector3?
    var screenCoords: ScreenRectangle?
    
    override public func mapping(map: Map) {
        super.mapping(map: map)

        intensity    <- map["Intensity"]
        worldCoords  <- (map["WorldCoords"], Vector3Transformer())
        screenCoords <- (map["ScreenCoords"], ScreenRectangleTransformer())
    }
}

class MotionEvent: BaseEvent {
    var motions: [MotionEntity]?

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        motions <- map["Motions"]
    }
}
