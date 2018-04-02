//
//  ViewController.swift
//  AppToolkitSampleApp
//
//  Created by Vasily Kolosovsky on 9/21/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit
import AppToolkit

class ConnectViewController: UIViewController {
    
    lazy var dataManager: RobotListDataManager = RobotListDataManager()
	
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var connectButton: UIButton!
    	@IBOutlet weak var connectToLocalhostButton: UIButton!
   	@IBOutlet weak var authButton: UIButton!
    	@IBOutlet weak var tableView: UITableView!

	fileprivate lazy var remote: CommandLibrary = CommandExecutor.shared.remote
    	fileprivate var isConnected: Bool = false
    	fileprivate var robotList: [RobotInfoProtocol]?
    	fileprivate var robot: Robot?
    
}

// MARK: Actions
extension ConnectViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupModule()
        setupDebugGesture()
        getRobots()
    }
    
    func setupTableView() {
        tableView.dataSource = dataManager
        tableView.delegate = dataManager
    }
    
    func setupModule() {
        self.dataManager.didSelectCell = { [weak self] robot in
            self?.didSelectAction(robot: robot)
        }
    }
    
    fileprivate func didSelectAction(robot: RobotInfoProtocol) {
        self.remote.getIpAddress(robot: robot, completion: { [unowned self] (rbt, error) in
            if let err = error {
                print("Failed to get robots ip: \(err)")
                self.updateViewOnError(err)
            } else {
                self.updateViewOnSuccess()
                self.robot = rbt
                
                print("port : \(self.robot!.getPort())")
                print("ip : \(self.robot!.getIp()!)")
                print("name : \(self.robot!.getName()!)")
                print("robotName : \(self.robot!.getRobotName()!)")
                self.updateButtonsState()
            }
        })
    }
    
    @IBAction func authButtonDidPressed(_ sender: UIButton) {
        if remote.isAuthenticated {
            invalidate()
        } else {
            authenticate()
        }
    }
    
	@IBAction func connectButtonDidPressed(_ sender: UIButton) {
        guard remote.isAuthenticated else { return }
        
        if isConnected {
			disconnect()
        } else {
			connect(robot)
        }
	}
	
	fileprivate func authenticate() {
		remote.authenticate(completion: { [unowned self] (success, error) in
			print("Autentication status - \(success)")
            self.getRobots()
		})
	}

    fileprivate func invalidate() {
        robot = nil
        remote.invalidate(completion: { [unowned self] (success, error) in
            self.updateButtonsState()
        })
    }

    fileprivate func getRobots() {
        guard remote.isAuthenticated else { return }

        remote.getRobotsList(completion: { [unowned self] (robots, err) in
            if let error = err {
                print("Failed to get robots list: \(error)")
            } else if let robots = robots {
                self.dataManager.update(data: robots) { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        })
    }
    
    fileprivate func connect(_ robot: Robot?) {
        guard let robot = robot else {
            getRobots()
            return
        }
        
        remote.connect(robot: robot, completion: { [unowned self] (success, error) in
            if success {
                self.isConnected = true
                
                self.remote.onConnectionStateChange = { [unowned self] (connected, error) in
                    self.isConnected = connected
                    if !connected {
                        self.navigationController?.popToRootViewController(animated: true)
                        if let err = error {
                            self.updateViewOnError(err)
                        } else {
                            self.updateViewOnSuccess()
                        }
					} else {
						self.updateViewOnSuccess()
					}
                }
                self.updateViewOnSuccess()
            } else if let error = error {
                self.updateViewOnError(error)
            }
        })
	}
	
	fileprivate func disconnect() {
		remote.onConnectionStateChange = nil
        remote.disconnect { (success, error) in
            if success {
                self.isConnected = false
                self.updateViewOnSuccess()
            } else if let error = error {
                self.updateViewOnError(error)
            }
        }
	}
	
	fileprivate func updateViewOnSuccess() {
		infoLabel.text = ""

        updateButtonsState()
        if isConnected {
            self.navigateOnConnected()
        }
	}
	
	fileprivate func updateViewOnError(_ error: Error) {
		connectButton.isEnabled = true
        infoLabel.text = "Failed to \(isConnected ? "stop" : "start") connection: \(error.localizedDescription)"
	}
	
	fileprivate func navigateOnConnected() {
		let viewController = RobotActionsViewController.controller(from: .main)
        viewController.robot = robot
		self.navigationController?.pushViewController(viewController, animated: true)
	}
    
    private func updateButtonsState() {
        DispatchQueue.main.async { [unowned self] in
            self.authButton.setTitle(self.remote.isAuthenticated ? "Invalidate" : "Authenticate", for: UIControlState.normal)
            self.connectButton.setTitle(self.isConnected ? "Disconnect" : "Connect", for: UIControlState.normal)
            self.connectButton.isEnabled = self.remote.isAuthenticated && self.robot != nil
        }
    }
}

extension ConnectViewController {
    
    func setupDebugGesture() {
        let rec = UILongPressGestureRecognizer(target: self, action: #selector(debugGestureRecognized(_:)))
        rec.numberOfTouchesRequired = 2
        rec.minimumPressDuration = 1
        
        self.view.addGestureRecognizer(rec)
    }
    
    @objc private func debugGestureRecognized(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .ended else { return }
        
        connectToLocalhostButton.isHidden = false
    }
    
    @IBAction func connectToLocalhost(_ sender: UIButton) {
        let robot = Robot(ip: "127.0.0.1", port: 7160, info: RobotInfo())
        connect(robot)
    }
}

class RobotInfo: RobotInfoProtocol {
    var id: String? = ""
    var name: String? = ""
    var robotName: String? = ""
    
}
