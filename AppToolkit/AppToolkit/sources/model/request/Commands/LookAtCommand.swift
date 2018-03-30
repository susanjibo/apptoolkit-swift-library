//
//  LookAtCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/// ID you get back from LPS system for entity. Entity can be face or motion or any other visual entity.
public typealias LookAtEntity = Int

//MARK: LookAt
/// Type of LookAt
public enum LookAtTargetType {
	/// 3D point in space
	case position(position: Vector3)
	/// Twist angle
	case angle(angle: AngleVector)
	/// 2D coordinates on Jibo's screen
	case screenCoords(screenCoords: Vector2)
	/// A face in Jibo's field of vision. Currently unsupported.
	case entity(entity: LookAtEntity)
}

/// :nodoc:
class LookAtCommand: Command {
	var lookAtTarget: LookAtTarget?
	var trackFlag: Bool?
	var levelHeadFlag: Bool?
	
	convenience init?(lookAtTargetType: LookAtTargetType, trackFlag: Bool, levelHeadFlag: Bool) {
		let map = Map(mappingType: .fromJSON, JSON: [:])
		self.init(map: map)
		
		self.lookAtTarget = LookAtTarget(lookAtTargetType: lookAtTargetType)
		self.trackFlag = trackFlag
		self.levelHeadFlag = levelHeadFlag
	}
	
	required init?(map: Map) {
		super.init(map: map)
		
		self.type = .lookAt
	}
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		
		lookAtTarget	<- map["LookAtTarget"]
		trackFlag 		<- map["TrackFlag"]
		levelHeadFlag	<- map["LevelHeadFlag"]
	}
}

class LookAtTarget: ModelObject {
	
	var lookAtTargetType: LookAtTargetType?
	
	convenience init?(lookAtTargetType: LookAtTargetType) {
		let map = Map(mappingType: .fromJSON, JSON: [:])
		self.init(map: map)
		
		self.lookAtTargetType = lookAtTargetType
	}
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		
		guard let lookAtTargetType = lookAtTargetType else { return }
		switch lookAtTargetType {
		case .position(var position):
			position <- (map["Position"], Vector3Transformer())
		case .angle(var angle):
			angle <- (map["Angle"], AngleVectorTransformer())
		case .screenCoords(var screenCoords):
			screenCoords <- (map["ScreenCoords"], Vector2Transformer())
		case .entity(var entity):
			entity <- map["Entity"]
		}
	}
}
