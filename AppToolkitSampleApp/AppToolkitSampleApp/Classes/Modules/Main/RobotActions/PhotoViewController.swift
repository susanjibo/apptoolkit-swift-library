//
//  PhotoViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 11/1/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import Alamofire
import AppToolkit

class PhotoViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
    @IBOutlet weak var consoleView: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    var command: Commands = .undefined
    lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
    var transactionId: String?
    var robot: Robot? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        executeCommand()
    }
    
    func executeCommand() {
        transactionId = commandExecutor.executeTakePhotoCommand(callback: { [unowned self] (photo, _) in
            if let photo = photo, let image = photo.image {
                self.imageView.image = image
            }
        })
        log("Executing PhotoCommand with transactionId \(transactionId ?? "EMPTY transactionId")")
    }
}
