//
//  VideoCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class VideoCommand: Command {
	
	var videoType: VideoType?
	var duration: Int?
	
	required init?(map: Map) {
		super.init(map: map)
		
		self.type = .video
	}
	
	convenience init?(videoType: VideoType, duration: TimeInterval) {
		self.init(map: Map(mappingType: .fromJSON, JSON: [:]))
		
		self.videoType = videoType
		self.duration = Int(duration)
	}
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		
		videoType 	<- map["VideoType"]
		duration	<- map["Duration"]
	}
}
