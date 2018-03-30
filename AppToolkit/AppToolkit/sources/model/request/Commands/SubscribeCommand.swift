//
//  SubscribeCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

enum StreamTypes: String {
    case undefined
    case entity = "Entity"
    case speech = "Speech"
    case headTouch = "HeadTouch"
    case motion = "Motion"
    case screenGesture = "ScreenGesture"
}

protocol BaseStreamFilterProtocol {
}

class BaseStreamFilter: ModelObject, BaseStreamFilterProtocol {
}

class BaseSubscribe: Command {
    var streamType: StreamTypes = .undefined
    var streamFilter: BaseStreamFilterProtocol? = BaseStreamFilter()
    
	required init?(map: Map) {
		super.init(map: map)
        
		self.type = .subscribe
	}
	
	override func mapping(map: Map) {
		super.mapping(map: map)
        
        streamType   <- map["StreamType"]
        streamFilter <- (map["StreamFilter"], BasicProtocolTypeSerializationTransform<BaseStreamFilter, BaseStreamFilterProtocol>())
	}
}

class EntityRequest: BaseSubscribe {
    required init?(map: Map) {
        super.init(map: map)
        
        self.streamType = .entity
    }
}

class SpeechRequest: BaseSubscribe {
    required init?(map: Map) {
        super.init(map: map)
        
        self.streamType = .speech
    }
}

class HeadTouchRequest: BaseSubscribe {
    required init?(map: Map) {
        super.init(map: map)
        
        self.streamType = .headTouch
    }
}

class MotionRequest: BaseSubscribe {
    required init?(map: Map) {
        super.init(map: map)
        
        self.streamType = .motion
    }
}

class ScreenGestureRequest: BaseSubscribe {
    required init?(map: Map) {
        super.init(map: map)
        
        self.streamType = .screenGesture
    }
    
    convenience init?(_ filter: ScreenGestureFilter?) {
        self.init(map: Map(mappingType: .fromJSON, JSON: [:]))

        self.streamFilter = filter
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        streamType <- map["StreamType"]
    }
    
    private var gestureFilter: ScreenGestureFilter? {
        return streamFilter as? ScreenGestureFilter
    }

}
