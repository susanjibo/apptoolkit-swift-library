//
//  JSONLoader.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

enum JsonResource: String {
	case responseError = "ResponseError"
	
	case lookAtPosition = "LookAtPositionCommand"
	case lookAtAngle = "LookAtAngleCommand"
	case lookAtScreenCoords = "LookAtScreenCoordsCommand"
	case lookAtEntity = "LookAtEntityCommand"
	
	case takeVideo = "TakeVideoCommand"
	case takeVideoDebug = "TakeVideoDebugCommand"
	
	case takePhotoHighRes = "TakePhotoHighRes"
	case takePhotoMediumRes = "TakePhotoMediumRes"
	case takePhotoLowRes = "TakePhotoLowRes"
	case takePhotoMicroRes = "TakePhotoMicroRes"
	case takePhotoLeftCameraDistortion = "TakePhotoLefCamDistortion"
	
	case cancelCommand = "CancelCommand"
	
	case sayCommand = "SayCommand"
	
	case getFaceEntity = "FaceEntity"
}

enum FileTypes: String {
	case json
}

final class JSONLoader {
	
	func loadJson(forResource resource: JsonResource) -> [String: Any]? {
		return loadJson(forResource: resource.rawValue, ofType: FileTypes.json.rawValue)
	}
	
    func loadObject<T: BaseMappable>(forResource resource: String, ofType fileType: String) -> T? {
		guard let json = loadJson(forResource: resource, ofType: fileType) else { return nil }
		
		return Mapper<T>().map(JSON: json)
    }
	
	func loadJsonString(forResource resource: String, ofType fileType: String) -> String? {
		guard let data = self.loadData(forResource: resource, ofType: fileType),
			let str = String(data: data, encoding: String.Encoding.utf8) else {
				return nil
		}
		return str
	}
	
	func loadJson(forResource resource: String, ofType fileType: String) -> [String: Any]? {
		guard let data = self.loadData(forResource: resource, ofType: fileType),
			let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
				return nil
		}
		return json
	}
	
	func loadData(forResource resource: String, ofType fileType: String) -> Data? {
		let bundle = Bundle(for: type(of: self))
		guard let path = bundle.path(forResource: resource, ofType: fileType),
			let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) else {
				return nil
		}
		return data
	}
	
}
