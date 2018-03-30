//
//  HeadTouchViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 12/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit

class HeadTouchViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
    var command: Commands = .undefined
    @IBOutlet weak var consoleView: UITextView!
    lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
    
    var activeTransactionId: String? {
        didSet {
            self.cancelTransaction(id: oldValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        executeCommand()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            activeTransactionId = nil
        }
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

extension HeadTouchViewController {
    func executeCommand() {
        activeTransactionId = commandExecutor.executeListenForHeadTouch(callback: { [unowned self] (info, err) in
            if let err = err {
                self.log("HeadTouch listening failed: \(err)")
            } else if let headTouchInfo = info, let sensors = headTouchInfo.headSensors {
                self.log("HeadTouch listening succeeded: \(sensors)")
            }
        })
        log("Executing HeadTouchCommand with transactionId \(activeTransactionId ?? "EMPTY transactionId")")
    }
}

