//
//  EntityEvent.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK: Tracking
/**
 When Jibo sees an entity, it is either a face and is recognized as a loop member,
 or is unknown
 */
public enum EntityType: String {
    /// Entity seen is a known loop member.
    case person = "person"
    /// Entity seen is not a loop member.
    case unknown = "unknown"
}

/**
 Protocol for tracking an entity
 */
public protocol TrackedEntityProtocol {
    /// ID of the entity
    var entityId: Int { get set }
    /// What kind of entity Jibo saw
    var type: EntityType { get set }
    /// How confident Jibo is in his identification of the entity.
    var confidence: Double { get set }
    /// 3D point in space where the entity exists.
    var worldCoords: Vector3 { get set }
    /// Rectangular area on Jibo's screen where the entity was seen.
    var screenCoords: ScreenRectangle { get set }
}

/// :nodoc:
class TrackedEntity: ModelObject, TrackedEntityProtocol {
    var entityId: Int = 0
    var type: EntityType = .unknown
    var confidence: Double = 0
    var worldCoords: Vector3 = Vector3.default
    var screenCoords: ScreenRectangle = ScreenRectangle.default

    override public func mapping(map: Map) {
        super.mapping(map: map)
        entityId        <- map["EntityID"]
        type            <- (map["Type"], EnumTransform<EntityType>())
        confidence      <- map["Confidence"]
        worldCoords     <- (map["WorldCoords"], Vector3Transformer())
        screenCoords    <- (map["ScreenCoords"], ScreenRectangleTransformer())
    }
}

/// :nodoc:
class EntityEvent: BaseEvent {
    var tracks: [TrackedEntity] = []
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        tracks <- map["Tracks"]
    }
}

