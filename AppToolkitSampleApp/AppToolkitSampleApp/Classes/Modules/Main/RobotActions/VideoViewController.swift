//
//  VideoViewController.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit
import WebKit

class VideoViewController: UIViewController, CommandConfigurable, ConsoleLoggable {
	
	@IBOutlet weak var videoViewContainer: UIView!
	@IBOutlet weak var consoleView: UITextView!
	
	var command: Commands = .undefined
    lazy var videoView = UIImageView()
	lazy var commandExecutor: CommandExecutor = CommandExecutor.shared
	var activeVideoTransactionId: String?
    var robot: Robot? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
        
		executeCommand()
		configVideoView()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		videoView.frame = videoViewContainer.frame
	}
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            cancelVideo()
        }
    }
    
	private func configVideoView() {
		videoViewContainer.addSubview(videoView)
	}
	
	@IBAction func cancelButtonDidPressed(_ sender: UIButton) {
        cancelVideo()
	}
	
    private func cancelVideo() {
        guard let activeVideoTransactionId = activeVideoTransactionId else {
            log("Nothing to cancel")
            return
        }
        log("Start cancelling videoTransactionId: \(activeVideoTransactionId)")
        commandExecutor.cancelCommand(transactionId: activeVideoTransactionId, completion: { [unowned self] (success, error) in
            if success {
                self.log("Cancelled videoTransactionId: \(activeVideoTransactionId)")
            } else {
                self.log("Command with transactionId: \(activeVideoTransactionId) cancellation failed with error: \(error?.localizedDescription ?? "Empty error")")
            }
        })
    }
}

extension VideoViewController {
	
	func executeCommand() {
        activeVideoTransactionId = commandExecutor.executeTakeVideoCommand(callback: { [unowned self] (frame, _) in
            if let image = frame {
                self.videoView.image = image
            }
        })
		log("Executing VideoCommand with transactionId \(activeVideoTransactionId ?? "EMPTY transactionId")")
	}
	
}
