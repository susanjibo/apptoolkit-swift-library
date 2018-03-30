//
//  Config.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK: Configuration Info
/**
 Info on the robot's battery
*/
public protocol BatteryProtocol: Mappable {
    /** `false` */
    var settable: Bool? { get set }
    /** Current capacity of the battery in amphours */
    var capacity: Double? { get set }
    /** Maximum capacity of the battery in amphours */
    var maxCapacity: Double? { get set }
    /** Charge rate of battery. Negative means draining. Positive means charging. */
    var chargeRate: Double? { get set }
}

/**
 Robot battery model object.
 */
public class Battery: ModelObject, BatteryProtocol {
    public var settable: Bool?
    public var capacity: Double?
    public var maxCapacity: Double?
    public var chargeRate: Double?
    
    override public func mapping(map: Map) {
        settable    <- map["Settable"]
        capacity    <- map["Capacity"]
        maxCapacity <- map["Max_capacity"]
        chargeRate  <- map["Charge_rate"]
    }
}

/**
 Info on the robot's current WiFi
 */
public protocol WiFiProtocol {
    /** Current WiFi strength */
    var strength: Double? { get set }
    /** `false` */
    var settable: Bool? { get set }
}

/** 
 Robot wifi model object.
 */
public class WiFi: ModelObject, WiFiProtocol {
    public var strength: Double?
    public var settable: Bool?

    override public func mapping(map: Map) {
        strength <- map["Strength"]
        settable <- map["Settable"]
    }
}

/** 
 Mixer info for volume levels for listening from Jibo's microphone array
 and talking through the speakers.
 */
public protocol MixersProtocol {
    /** Volume level for Jibo's hardware */
    var master: Double? { get set }
    /** `true` */
    var settable: Bool? { get set }
}

/**
 Robot mixer model object.
 */
public class Mixers: ModelObject, MixersProtocol {
    public var master: Double?
    public var settable: Bool?
    
    override public func mapping(map: Map) {
        master   <- map["Master"]
        settable <- map["Settable"]
    }
}

/**
 Jibo's current position, defined as his global 3D position and his 2D twist position.
 */
public protocol PositionProtocol {
    /** Global position */
    var worldPosition: Vector3? { get set }
    /** Twist */
    var anglePosition: AngleVector? { get set }
}

/**
 Robot position model object.
 */
public class Position: ModelObject, PositionProtocol {
    public var worldPosition: Vector3?
    public var anglePosition: AngleVector?
    
    override public func mapping(map: Map) {
        worldPosition <- (map["WorldPosition"], Vector3Transformer())
        anglePosition <- (map["AnglePosition"], AngleVectorTransformer())
    }
}

/**
 Robot configuration options
 */
public protocol SetConfigOptionsProtocol {
    /** Robot volume */
    var mixer: Double? { get set }
}

/**
 Robot configuration setter model object.
 */
public class SetConfigOptions: ModelObject, SetConfigOptionsProtocol {
    public var mixer: Double?
    
    override public func mapping(map: Map) {
        mixer <- map["Mixer"]
    }
}

/**
 Robot info and configuration options
 */
public protocol ConfigInfoProtocol {
    /** Battery state */
    var battery: BatteryProtocol? { get set }
    /** WiFi info */
    var wifi: WiFiProtocol? { get set }
    /** Jibo's current position */
    var position: PositionProtocol? { get set }
    /** Volume info */
    var mixers: MixersProtocol? { get set }
}

/**
 Robot configuration model object.
 */
public class ConfigInfo: ModelObject, ConfigInfoProtocol {
    public var battery: BatteryProtocol?
    public var wifi: WiFiProtocol?
    public var position: PositionProtocol?
    public var mixers: MixersProtocol?
    
    override public func mapping(map: Map) {
        battery  <- (map["Battery"], BasicProtocolTypeSerializationTransform<Battery, BatteryProtocol>())
        wifi     <- (map["Wifi"], BasicProtocolTypeSerializationTransform<WiFi, WiFiProtocol>())
        position <- (map["Position"], BasicProtocolTypeSerializationTransform<Position, PositionProtocol>())
        mixers   <- (map["Mixers"], BasicProtocolTypeSerializationTransform<Mixers, MixersProtocol>())
    }
}

