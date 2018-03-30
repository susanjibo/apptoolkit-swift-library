//
//  TakePhotoCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class TakePhotoCommand: Command {
	var camera: Camera?
	var distortion: Bool?
	var resolution: CameraResolution?
	
	required init?(map: Map) {
		super.init(map: map)
		
		self.type = .takePhoto
	}
	
    convenience init?(camera: Camera, resolution: CameraResolution, distortion: Bool) {
        self.init(map: Map(mappingType: .fromJSON, JSON: [:]))

        self.camera = camera
        self.resolution = resolution
        self.distortion = distortion
    }

    override func mapping(map: Map) {
		super.mapping(map: map)
		
		camera     <- map["Camera"]
		resolution <- map["Resolution"]
		distortion <- map["Distortion"]
	}
}
