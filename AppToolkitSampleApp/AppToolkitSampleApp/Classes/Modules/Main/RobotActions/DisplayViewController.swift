//
//  DisplayViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 12/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit

class DisplayViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
    var command: Commands = .undefined
    @IBOutlet weak var consoleView: UITextView!
    lazy var commandExecutor: CommandExecutor = CommandExecutor.shared

    var activeTransactionId: String? {
        didSet {
            self.cancelTransaction(id: oldValue)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            activeTransactionId = nil
        }
    }
    
    @IBAction func displayButtonDidPressed(_ sender: UIButton) {
        activeTransactionId = nil
        showDisplayActionSheet()
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
    
    fileprivate func showDisplayActionSheet() {
        activeTransactionId = nil
        present(makeDisplayActionSheet(), animated: true, completion: nil)
    }
    
    fileprivate func makeDisplayActionSheet() -> UIAlertController {
        let actionSheet = UIAlertController(title: "Display", message: "Choose \"Display\" type", preferredStyle: .actionSheet)
        let displayEyeAction = UIAlertAction(title: "Display Eye", style: .default, handler: { [unowned self] _ in
            self.log("Start executing Display Eye")
            self.activeTransactionId = self.commandExecutor.executeDisplayEye("testView", callback: { (info, err) in
                if let err = err {
                    self.log("Display Eye failed: \(err)")
                } else if let displayInfo = info {
                    self.log("Display Eye succeeded: \(displayInfo)")
                }
            })
            self.log("Executing TransactionId: \(self.activeTransactionId ?? "Empty")")
        })

        let displayTextAction = UIAlertAction(title: "Display Text", style: .default, handler: { [unowned self] _ in
            self.log("Start executing Display Text")
            self.activeTransactionId = self.commandExecutor.executeDisplayText("Hello there!!!", in: "testView", callback: { (info, err) in
                if let err = err {
                    self.log("Display Text failed: \(err)")
                } else if let displayInfo = info {
                    self.log("Display Text succeeded: \(displayInfo)")
                }
            })
            self.log("Executing TransactionId: \(self.activeTransactionId ?? "Empty")")
        })

        let displayImageAction = UIAlertAction(title: "Display Image", style: .default, handler: { [unowned self] _ in
            self.log("Start executing Display Image")
            let uri = "https://upload.wikimedia.org/wikipedia/commons/d/d2/2010_Cynthia_Breazeal_4641804653.png"
            let name = "cynthia"
            self.activeTransactionId = self.commandExecutor.executeFetchAsset(uri, name: name, callback: { [unowned self] (info, err) in
                if let assetInfo = info, let _ = assetInfo.detail {
                    let data = ImageData(name, source: uri)
                    self.activeTransactionId = self.commandExecutor.executeDisplayImage(data, in: "testView", callback: { (info, err) in
                        if let err = err {
                            self.log("Display Image failed: \(err)")
                        } else if let displayInfo = info {
                            self.log("Display Image succeeded: \(displayInfo)")
                        }
                    })
                    self.log("Executing display TransactionId: \(self.activeTransactionId ?? "Empty")")
                }
            })
            self.log("Executing Fetch TransactionId: \(self.activeTransactionId ?? "Empty")")
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let actionSheetActions = [displayEyeAction, displayTextAction, displayImageAction, cancelAction]
        actionSheetActions.forEach(actionSheet.addAction)
        
        return actionSheet
    }
}

