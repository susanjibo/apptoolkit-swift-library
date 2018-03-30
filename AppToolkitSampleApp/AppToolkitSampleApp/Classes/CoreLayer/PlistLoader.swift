//
//  PlistLoader.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class PlistLoader {
	
	fileprivate static let fileExt = "plist"
	
	struct Keys {
		static let commands = "Commands"
	}
	
	enum Plists: String {
		case robotApiCategories = "RobotApiCategories"
	}
	
	static func loadCommands() -> [[String: Any]] {
		return loadRobotApiCategories()[Keys.commands] as? [[String: Any]] ?? []
	}
	
	static func loadRobotApiCategories() -> [String: Any] {
		return load(fileName: .robotApiCategories)
	}
	
	fileprivate static func load(fileName: Plists) -> [String: Any] {
		if let fileUrl = Bundle.main.url(forResource: fileName.rawValue, withExtension: fileExt),
			let data = try? Data(contentsOf: fileUrl) {
			if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
				let resultDict = result as? [String: Any] {
				
				return resultDict
			}
		}
		return [:]
	}
	
}
