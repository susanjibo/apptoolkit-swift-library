//
//  FetchAssetViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 12/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit

class FetchAssetViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
    var command: Commands = .undefined
    @IBOutlet weak var consoleView: UITextView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var uriField: UITextField!
    lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uriField.text = "https://upload.wikimedia.org/wikipedia/commons/d/d2/2010_Cynthia_Breazeal_4641804653.png"
        nameField.text = "testImage"
    }
    
    var activeTransactionId: String? {
        didSet {
            self.cancelTransaction(id: oldValue)
        }
    }
    
    @IBAction func fetchButtonDidPressed(_ sender: UIButton) {
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

extension FetchAssetViewController {
    func executeCommand() {
        activeTransactionId = commandExecutor.executeFetchAsset(uriField.text!, name: nameField.text!, callback: { [unowned self] (info, err) in
            if let err = err {
                self.log("FetchAsset failed: \(err)")
            } else if let assetInfo = info, let detail = assetInfo.detail {
                self.log("FetchAsset succeeded: \(detail)")
            }
        })
        log("Executing FetchAssetCommand with transactionId \(activeTransactionId ?? "EMPTY transactionId")")
    }
}


