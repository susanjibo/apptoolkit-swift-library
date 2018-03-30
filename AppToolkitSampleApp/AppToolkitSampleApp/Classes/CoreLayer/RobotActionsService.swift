//
//  RobotActionsService.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class RobotActionsSerice {
	
	func loadRobotActions() -> [RobotAction] {
		let actionsRawValue = PlistLoader.loadCommands()
		let actions = actionsRawValue.flatMap(RobotAction.create)
		
		return actions
	}
	
}

class RobotAction: CustomStringConvertible {
	
	struct Keys {
		static let title = "title"
		static let raw = "raw"
	}
	
	let title: String
	let command: Commands
	
	private init?(title: String?, raw: String?) {
		guard let title = title,
			let raw = raw,
			let command = Commands(rawValue: raw)  else { return nil }
		self.title = title
		self.command = command
			
	}
	
	static func create(from dict: [String: Any]) -> RobotAction? {
		let title = dict[Keys.title] as? String
		let raw = dict[Keys.raw] as? String
		return RobotAction(title: title, raw: raw)
	}
	
	var description: String {
		return "title: \(title)"
	}
}
