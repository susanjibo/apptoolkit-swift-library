//
//  EventMessage.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

let EventBodyID = "EventBody"
let EventID = "Event"
let ListenStopReasonID = "StopReason"

class EventHeader: ResponseHeader {
    var timestamp: Double?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        timestamp   <- map["Timestamp"]
    }
}

class EventMessage: ResponseBase {
    var header: EventHeader?
    var body: BaseEvent?

    override func mapping(map: Map) {
        header <- map[EventHeaderID]
        body   <- (map[EventBodyID], BaseEventSerializationTransform())
    }
    
    override func isEvent() -> Bool {
        return true
    }
}

final class BaseEventSerializationTransform: TransformType {
    typealias Object = BaseEvent
    typealias JSON = [String: AnyObject]


    public func transformFromJSON(_ value: Any?) -> BaseEvent? {
        guard let json = value as? JSON else { return nil }
        return baseEvent(from: eventType(from: json), json: json)
    }

    public func transformToJSON(_ value: BaseEvent?) -> [String : AnyObject]? {
        assertionFailure("Not implemented")
        return nil
    }

    fileprivate func eventType(from json: JSON) -> EventType {
        if let event = json[EventID] as? String {
            let type = EventType(rawValue: event) ?? .undefined
            
            //edge case for Listen
            if type == .asyncStop, let _ = json[ListenStopReasonID] as? String {
                return .listenStop
            }
            return type
        } else {
            return .undefined
        }
    }

    // map JSON to model objects, using content analyze
    fileprivate func baseEvent(from type: EventType, json: JSON) -> BaseEvent? {
        switch type {
        case .asyncStart:           return Mapper<AsyncStatusEvent>().map(JSON: json)
        case .asyncStop:            return Mapper<AsyncStatusEvent>().map(JSON: json)
        case .asyncError:           return Mapper<AsyncErrorEvent>().map(JSON: json)
        case .trackUpdate:          return Mapper<EntityEvent>().map(JSON: json)
        case .trackLost:            return Mapper<EntityEvent>().map(JSON: json)
        case .trackGained:          return Mapper<EntityEvent>().map(JSON: json)
        case .lookAtAchieved:       return Mapper<LookAtEvent>().map(JSON: json)
        case .trackEntityLost:      return Mapper<LookAtEvent>().map(JSON: json)
        case .videoReady:           return Mapper<VideoReadyEvent>().map(JSON: json)
        case .takePhoto:            return Mapper<TakePhotoEvent>().map(JSON: json)
        case .viewStateChange:      return Mapper<DisplayViewStateEvent>().map(JSON: json)
        case .motionDetected:       return Mapper<MotionEvent>().map(JSON: json)
        case .listenResult:         return Mapper<ListenResultEvent>().map(JSON: json)
        case .onHotWordHeard:       return Mapper<HotWordHeardEvent>().map(JSON: json)
        case .listenStop:           return Mapper<ListenStopEvent>().map(JSON: json)
        case .headTouched:          return Mapper<HeadTouchEvent>().map(JSON: json)
        case .assetReady:           return Mapper<FetchAssetEvent>().map(JSON: json)
        case .assetFailed:          return Mapper<FetchAssetErrorEvent>().map(JSON: json)
        case .onConfig:             return Mapper<ConfigEvent>().map(JSON: json)
        case .onScreenTap:          return Mapper<ScreenGestureTapEvent>().map(JSON: json)
        case .onScreenSwipe:        return Mapper<ScreenGestureSwipeEvent>().map(JSON: json)
        case .undefined:            return nil
        }
    }
}
