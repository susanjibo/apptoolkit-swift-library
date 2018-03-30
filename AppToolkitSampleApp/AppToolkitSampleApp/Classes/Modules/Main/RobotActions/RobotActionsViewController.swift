//
//  RobotActionsViewController.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit

class RobotActionsViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	lazy var dataManager: RobotActionsDataManager = RobotActionsDataManager()
	lazy var service = RobotActionsSerice()
    var robot: Robot? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		
        setupTableView()
		setupModule()
	}
	
	func setupModule() {
		let actions = service.loadRobotActions()
		self.dataManager.didSelectCell = { [weak self] action in
			self?.didSelectAction(action: action)
		}
		self.dataManager.update(data: actions) { [weak self] in
			self?.tableView.reloadData()
		}
	}
	
	func setupTableView() {
		tableView.dataSource = dataManager
		tableView.delegate = dataManager
	}
	
	fileprivate func didSelectAction(action: RobotAction) {
		navigate(for: action)
	}
	
	fileprivate func navigate(for action: RobotAction) {
		let factory = CommandResultControllersFactory()
        guard let viewController = factory.viewController(for: action.command, robot: robot) else { return }
		viewController.title = action.title
		navigationController?.pushViewController(viewController, animated: true)
	}
	
}
