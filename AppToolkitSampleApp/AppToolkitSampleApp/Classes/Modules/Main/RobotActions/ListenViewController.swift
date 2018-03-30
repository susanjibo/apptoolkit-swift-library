//
//  ListenViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 12/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit

class ListenViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
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

extension ListenViewController {
    func executeCommand() {
        activeTransactionId = commandExecutor.executeListenForSpeech(callback: { [unowned self] (info, err) in
            if let err = err {
                self.log("Speech listening failed: \(err)")
            } else if let speechInfo = info, let type = speechInfo.listenType {
                self.log("Speech listening succeeded: \(type)")
                switch type {
                case .speech(let speech):
                    self.log("Jibo recognized: \(speech.speech!)")
                case .hotWord(let hotWord):
                    self.log("Jibo recognized hot word: \(hotWord.speaker!)")
                case .stop(let reason):
                    self.log("Jibo stopped voice recognition: \(reason)")
                }
            }
        })
        log("Executing ListenCommand with transactionId \(activeTransactionId ?? "EMPTY transactionId")")
    }
}
