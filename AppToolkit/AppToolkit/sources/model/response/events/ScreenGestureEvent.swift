//
//  ScreenGestureEvent.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/14/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import ObjectMapper

public protocol ScreenGestureEntityProtocol {
    /// Coordinate on the screen
    var coordinate: Vector2? { get set }
    /// Direction of the swipe
    var direction: ScreenGestureSwipeDirection? { get set }
    // Velocity of the gesture
    var velocity: Vector2?{ get set }
}

class ScreenGestureEntity: ModelObject, ScreenGestureEntityProtocol {
    var coordinate: Vector2? = nil
    var direction: ScreenGestureSwipeDirection? = nil
    var velocity: Vector2? = nil
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        coordinate <- (map["Coordinate"], Vector2Transformer())
        direction <- map["Direction"]
        velocity  <- (map["Velocity"], Vector2Transformer())
    }
}

class ScreenGestureEvent: BaseEvent {
    var gesture: ScreenGestureEntity?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        gesture <- map["Gesture"]
    }
}

class ScreenGestureTapEvent: BaseEvent {
    var coordinate: Vector2? = nil
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        coordinate <- (map["Coordinate"], Vector2Transformer())
    }
}

class ScreenGestureSwipeEvent: BaseEvent {
    var direction: ScreenGestureSwipeDirection? = nil
    var velocity: Vector2? = nil
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        direction <- map["Direction"]
        velocity  <- (map["Velocity"], Vector2Transformer())
    }
}
