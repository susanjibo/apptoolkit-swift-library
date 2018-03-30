//
//  SetConfigViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 12/12/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit

class SetConfigViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
    var command: Commands = .undefined
    @IBOutlet weak var consoleView: UITextView!
    @IBOutlet weak var mixer: UITextField!
    lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
    
    var activeTransactionId: String? {
        didSet {
            self.cancelTransaction(id: oldValue)
        }
    }
    
    @IBAction func setConfigButtonDidPressed(_ sender: UIButton) {
        activeTransactionId = nil
        executeCommand()
    }
    
    @IBAction func cancelButtonDidPressed(_ sender: UIButton) {
        activeTransactionId = nil
    }
    
    fileprivate func cancelTransaction(id: TransactionId?) {
        guard let transactionToCancel = id else {
            return
        }
        commandExecutor.cancelCommand(transactionId: transactionToCancel, completion: nil)
    }
    
}

extension SetConfigViewController {
    func executeCommand() {
        struct SetInfo: SetConfigOptionsProtocol {
            var mixer: Double?
        }
        let info = SetInfo(mixer: Double(mixer.text!) ?? 0)
        activeTransactionId = commandExecutor.executeSetConfigCommand(info, completion: { (info, err) in
            if let err = err {
                self.log("SetConfig failed: \(err)")
            } else if let configInfo = info {
                self.log("SetConfig result: \(configInfo.succeed)")
            }
        })
        log("Executing SetConfigCommand with transactionId \(activeTransactionId ?? "EMPTY transactionId")")
    }
}


