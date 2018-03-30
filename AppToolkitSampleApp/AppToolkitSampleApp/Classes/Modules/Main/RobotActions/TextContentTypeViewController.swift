//
//  TexyContentTypeViewController.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit

class TextContentTypeViewController: UIViewController, CommandConfigurable {
	
	@IBOutlet weak var contentLabel: UILabel!
	var command: Commands = .undefined
	lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.executeCommand()
	}
	
	func executeCommand() {
		switch command {
		case .getConfig:
			self.executeGetConfigAndConfigureViewWithResult()
		case .faceEntity:
			self.executeGetFaceEntity()
		default:
			break
		}
	}
	
	func executeGetFaceEntity() {
        _ = self.commandExecutor.executeGetFaceEntity(callback: { (info, err) in
            if let err = err {
                print("GetFace failed: \(err)")
            } else if let entityInfo = info {
                print("GetFace succeeded: \(entityInfo)")
            }
        })

	}
    
	
	func executeGetConfigAndConfigureViewWithResult() {
        _ = commandExecutor.executeGetConfigCommand(completion: { [unowned self] (config, error) in
            if let error = error {
                self.configView(with: error)
            } else if let config = config, let info = config.info {
                self.configView(with: info)
            }
        })
		contentLabel.text = "Waiting for response or not implemented in SDKSkills"
	}
	
	func configView(with configData: ConfigInfoProtocol) {
        let battery = "Battery: capacity - \(configData.battery?.capacity), chargeRate - \(configData.battery?.chargeRate), maxCapacity - \(configData.battery?.maxCapacity)"
        let wifi = "WiFi: strength - \(configData.wifi?.strength), settable - \(configData.wifi?.settable)"
        let position = "Position: worldPosition - \(configData.position?.worldPosition), anglePosition - \(configData.position?.anglePosition)"
        let mixers = "Mixers: master - \(configData.mixers?.master), settable - \(configData.mixers?.settable)"
        contentLabel.text = "Get config succeed: \n\(battery)\n\(wifi)\n\(position)\n\(mixers)\n"
	}
	
	func configView(with error: Error?) {
		guard let error = error else {
			contentLabel.text = "Error is empty"
			return
		}
		
		contentLabel.text = error.localizedDescription
	}
}
