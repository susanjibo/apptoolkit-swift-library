//
//  RobotActionsDataManager.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit

class RobotActionsDataManager: NSObject {
	typealias RobotActionsCellAction = (RobotAction) -> ()
	typealias RobotActionsUpdated = () -> ()
	
	fileprivate let cellReuseId = "PrototypeCell"
	
	var didSelectCell: RobotActionsCellAction?
	var actions: [RobotAction]
	
	init(actions: [RobotAction]) {
		self.actions = actions
	}
	
	convenience override init() {
		self.init(actions: [])
	}
	
	func update(data actions: [RobotAction], completion: RobotActionsUpdated? = nil) {
		self.actions = actions
		completion?()
	}
}

extension RobotActionsDataManager: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return actions.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseId) ?? UITableViewCell()
		cell.selectionStyle = .none
		return cell
	}
	
}

extension RobotActionsDataManager: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.textLabel?.text = actions[indexPath.row].title
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		didSelectCell?(actions[indexPath.row])
	}
	
}
