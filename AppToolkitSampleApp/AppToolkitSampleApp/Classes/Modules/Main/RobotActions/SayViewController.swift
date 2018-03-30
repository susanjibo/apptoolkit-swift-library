//
//  SayViewController.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/10/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit

class SayViewController: UIViewController, CommandConfigurable, ConsoleLoggable  {
	
	var command: Commands = .say
	lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
	
	@IBOutlet weak var consoleView: UITextView!
	@IBOutlet weak var phraseTextField: UITextField!
	
	var activeTransactionId: String? {
		didSet {
			self.cancelTransaction(id: oldValue)
		}
	}
	
	@IBAction func sayButtonDidPressed(_ sender: UIButton) {
		guard let text = phraseTextField.text, !text.isEmpty else {
			return
		}
		self.activeTransactionId = self.commandExecutor.executeSayCommand(phrase: text, completion: { (info, _) in
			guard let info = info else { return }
			switch info.type {
			case .asyncStop:
				print("Execution stopped")
			default:
				print("\(info.type)")
			}
		})
	}
	
	@IBAction func cancelButtonDidPressed(_ sender: UIButton) {
		self.cancelTransaction(id: self.activeTransactionId)
	}
	
	fileprivate func cancelTransaction(id: TransactionId?) {
		guard let transactionToCancel = id else {
			return
		}
		commandExecutor.cancelCommand(transactionId: transactionToCancel, completion: nil)
	}
}
