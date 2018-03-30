//
//  ListenEvent.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK: Listen
/**
 When Jibo listen to human speach and returns the text, or the Speaker object for "Hey, Jibo" command (not impemented jet)
 */

/**
 Protocol for listen an entity
 */
public protocol ListenEntityProtocol {
    /// Regular speech
    var speech: String? { get set }
    var languageCode: String? { get set }
    /// "Hey Jibo". Currently unsupported
    var speaker: Speaker? { get set }
    /// "Stop"
    var reason: String? { get set }
}

/**
 Entity for listen
 */
class ListenEntity: ModelObject, ListenEntityProtocol {
    var speech: String?
    var languageCode: String?
    var speaker: Speaker?
    var reason: String?
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        speech    <- map["Speech"]
        languageCode    <- map["LanguageCode"]
        speaker    <- map["Speaker"]
        reason    <- map["Reason"]
    }
}

/**
 Base Listen event
 */
class ListenEvent: BaseEvent {
    var listen: ListenEntity?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        listen <- map["Listen"]
    }
}

/**
 Enum for listen stop reason
 */
enum ListenStopReason: String {
    case maxNoSpeech = "maxNoSpeech"
    case maxSpeech = "maxSpeech"
}

/**
 Base Stop Listen event
 */
class ListenStopEvent: BaseEvent {
    var stopReason: ListenStopReason?

    override func mapping(map: Map) {
        super.mapping(map: map)
        stopReason <- (map[ListenStopReasonID], EnumTransform<ListenStopReason>())
    }
    
    override var event: EventType {
        set {
            //no-op
        }
        get {
            return .listenStop
        }
    }
}

/**
 Base Listen result event
 */
class ListenResultEvent: BaseEvent {
    var languageCode: String?
    var speech: String = ""
    var nluResult: NLUResult?

    override func mapping(map: Map) {
        super.mapping(map: map)
        languageCode <- map["LanguageCode"]
        speech       <- map["Speech"]
    }
}

/**
 Base Listen "HotWord" result event
 */
class HotWordHeardEvent: BaseEvent {
    struct LPSPosition: Mappable {
        var position: Vector3?
        var angleVector: Vector2?
        var confidence: Double?

        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            position    <- map["Position"]
            angleVector <- map["AngleVector"]
            confidence  <- map["Confidence"]
        }
        
    }
    
    struct SpeakerId: Mappable {
        var type: EntityType?
        var confidence: Double?

        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            type        <- map["Type"]
            confidence  <- map["Confidence"]
        }
    }

    struct Speaker: Mappable {
        var lpsPosition: LPSPosition?
        var speakerID: SpeakerId?
        
        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            lpsPosition <- map["LPSPosition"]
            speakerID   <- map["SpeakerId"]
        }
    }
    var speaker: Speaker?

    override func mapping(map: Map) {
        super.mapping(map: map)

        speaker <- map["Speaker"]
    }
}
