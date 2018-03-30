//
//  MotionViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 12/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit

class MotionViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
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

extension MotionViewController {
    
    func executeCommand() {
        activeTransactionId = commandExecutor.executeGetMotion(callback: { [unowned self] (info, err) in
            if let err = err {
                self.log("Motion listening failed: \(err)")
            } else if let motionInfo = info {
                self.log("Motion listening succeeded: \(motionInfo)")
                motionInfo.motions?.forEach({ (m) in
                    self.log("Intensity: \(m.intensity), screen coords: \(m.screenCoords), world coords \(m.worldCoords)")
                })
            }
        })
        log("Executing MotionCommand with transactionId \(activeTransactionId ?? "EMPTY transactionId")")
    }
    
}

