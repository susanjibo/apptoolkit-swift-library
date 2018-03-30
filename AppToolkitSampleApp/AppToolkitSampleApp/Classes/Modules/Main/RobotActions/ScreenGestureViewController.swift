//
//  ScreenGestureViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 12/14/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit

class ScreenGestureViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
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

extension ScreenGestureViewController {
    func executeCommand() {
        
        activeTransactionId = commandExecutor.executeListenForScreenGesture(ScreenGestureListenParams(type: .tap, area: Rectangle(x: 0, y: 0, width: 1280, height: 720)), callback: { (info, err) in
            if let err = err {
                self.log("ScreenGesture failed: \(err)")
            } else if let gestureInfo = info, let type = gestureInfo.gestureType {
                switch type {
                case .tap(let coordinate):
                    self.log("ScreenGesture tap succeeded: \(coordinate)")
                case .swipe(let direction, let velocity):
                    self.log("ScreenGesture swipe succeeded: \(direction): \(velocity)")
                }
            }
        })
        log("Executing ScreenGestureCommand with transactionId \(activeTransactionId ?? "EMPTY transactionId")")
    }
}
