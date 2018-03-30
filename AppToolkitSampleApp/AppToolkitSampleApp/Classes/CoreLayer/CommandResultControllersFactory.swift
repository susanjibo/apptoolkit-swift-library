//
//  CommandExecutor.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import AppToolkit
import UIKit

enum Commands: String {
	case undefined
	case getConfig
    case setConfig
	case lookAt
	case video
    case photo
	case say
	case listen
	case faceEntity
    case display
    case motion
    case headTouch
    case fetchAsset
	case screenGesture
}

enum LookAtType: String {
	case position 		= "Position"
	case angle 			= "Angle"
	case screenCoords 	= "Screen Coordinates"
	case entity			= "Entity"
	
	static var allValues: [LookAtType] = [.position, .angle, .screenCoords, .entity]
	static var allRawValues: [String] = allValues.flatMap { $0.rawValue }
	
	var targetType: LookAtTargetType {
		switch self {
		case .position:
			let vector3 = Vector3(x: 0, y: 3.14, z: 0)
			return LookAtTargetType.position(position: vector3)
		case .angle:
			let angle = AngleVector(theta: 0, psi: 1.57)
			return LookAtTargetType.angle(angle: angle)
		case .screenCoords:
			let vector2 = Vector2(x: 0, y: 5)
			return LookAtTargetType.screenCoords(screenCoords: vector2)
		case .entity:
			return LookAtTargetType.entity(entity: 1)
		}
	}
}

typealias TransactionId = String

protocol CommandConfigurable where Self: UIViewController {
	var command: Commands {get set}
}

protocol ConsoleLoggable where Self: UIViewController {
	var consoleView: UITextView! { get set }
}
extension ConsoleLoggable {
	func log(_ msg: String) {
		let logMsg = "\(msg)\n\(consoleView.text ?? "")"
		consoleView.text = logMsg
	}
}

class CommandExecutor {
	
	static let shared: CommandExecutor = CommandExecutor()
	private init() { }
	
	lazy var remote: CommandLibrary = CommandLibrary()
	
    @discardableResult
	func executeGetConfigCommand(completion: CommandLibrary.GetConfigClosure?) -> TransactionId? {
		return remote.getConfiguration(completion: completion)
	}
	
    @discardableResult
    func executeSetConfigCommand(_ options: SetConfigOptionsProtocol, completion: CommandLibrary.SetConfigClosure?) -> TransactionId? {
        return remote.setConfiguration(options, completion: completion)
    }

    @discardableResult
	func executeTakeVideoCommand(callback: CommandLibrary.TakeVideoClosure?) -> TransactionId? {
        return remote.takeVideo(duration: 1.0, completion: callback)
	}
	
	func cancelCommand(transactionId: String,
	                   completion: CommandLibrary.CompletionHandler?) {
		remote.cancel(transactionId: transactionId, completion: completion)
	}
	
    func executeLookAtCommand(lookAt: LookAtType, callback: CommandLibrary.LookAtClosure?) -> TransactionId? {
        return remote.lookAt(targetType: lookAt.targetType, trackFlag: false, levelHeadFlag: false, completion: callback)
	}
	
	func executeSayCommand(phrase: String,
                           completion: CommandLibrary.SayClosure?) -> TransactionId? {
		return remote.say(phrase: phrase, completion: completion)
	}
	
	func executeGetFaceEntity(callback: CommandLibrary.TrackedEntityClosure?) -> TransactionID? {
        return remote.getFaceEntity(completion: callback)
	}
    
    func executeTakePhotoCommand(camera: Camera = .left, resolution: CameraResolution = .medium, distortion: Bool = true, callback: CommandLibrary.TakePhotoClosure?) -> TransactionId? {
        return remote.takePhoto(camera: camera, resolution: resolution, distortion: distortion, completion: callback)
    }
    
    func executeDisplayEye(_ view: String, callback: CommandLibrary.DisplayClosure?) -> TransactionID? {
        return remote.displayEye(in: view, completion: callback)
    }

    func executeDisplayText(_ text: String, in view: String, callback: CommandLibrary.DisplayClosure?) -> TransactionID? {
        return remote.displayText(text, in: view, completion: callback)
    }

    func executeDisplayImage(_ image: ImageData, in view: String, callback: CommandLibrary.DisplayClosure?) -> TransactionID? {
        return remote.displayImage(image, in: view, completion: callback)
    }
    
    func executeGetMotion(callback: CommandLibrary.MotionClosure?) -> TransactionID? {
        return remote.getMotion(completion: callback)
    }

    func executeListenForSpeech(maxSpeechTimeOut: Timeout = 15, maxNoSpeechTimeout: Timeout = 15, languageCode: LangCode = .enUS, callback: CommandLibrary.ListenClosure?) -> TransactionID? {
        return remote.listenForSpeech(maxSpeechTimeOut: maxSpeechTimeOut, maxNoSpeechTimeout: maxNoSpeechTimeout, languageCode: languageCode, completion: callback)
    }

    func executeListenForHeadTouch(callback: CommandLibrary.HeadTouchClosure?) -> TransactionID? {
        return remote.listenForHeadTouch(completion:callback)
    }

    @discardableResult
    func executeFetchAsset(_ uri: String, name: String, callback: CommandLibrary.FetchAssetClosure?) -> TransactionID? {
        return remote.fetchAssetWithURI(uri, name: name, completion: callback)
    }

    func executeListenForScreenGesture(_ params: ScreenGestureListenParams, callback: CommandLibrary.ScreenGestureClosure?) -> TransactionID? {
        return remote.listenForScreenGesture(params, completion: callback)
    }
    
}

class CommandResultControllersFactory {
	
    func viewController(for command: Commands, robot: Robot?) -> UIViewController? {
		switch command {
		case .getConfig:
			return simpleTextViewController(command: command)
        case .setConfig:
            return setConfigViewController(command: command)
		case .video:
			return videoViewController(command: command, robot: robot)
		case .lookAt:
			return lookAtViewController(command: command)
		case .say:
			return sayViewController(command: command)
		case .faceEntity:
			return simpleTextViewController(command: command)
        case .photo:
            return photoViewController(command: command, robot: robot)
        case .display:
            return displayViewController(command: command)
        case .motion:
            return motionViewController(command: command)
        case .undefined:
            print("Error: should never be happen!!!")
            break
        case .listen:
            return listenViewController(command: command)
        case .headTouch:
            return headTouchViewController(command: command)
        case .fetchAsset:
            return fetchAssetViewController(command: command)
        case .screenGesture:
            return screenGestureViewController(command: command)
//            print("\nNot implemented yet: \(command)\n")
        }
		return nil
	}
	
	fileprivate func viewController<T: CommandConfigurable>(type: T.Type, command: Commands) -> T {
		var viewController = type.controller(from: .main)
		viewController.command = command
		return viewController
	}
	
	fileprivate func simpleTextViewController(command: Commands) -> TextContentTypeViewController {
		return self.viewController(type: TextContentTypeViewController.self, command: command)
	}
	
    fileprivate func setConfigViewController(command: Commands) -> SetConfigViewController {
        let config = self.viewController(type: SetConfigViewController.self, command: command)
        return config
    }

    fileprivate func videoViewController(command: Commands, robot: Robot?) -> VideoViewController {
		let video = self.viewController(type: VideoViewController.self, command: command)
        video.robot = robot
        return video
	}
	
	fileprivate func lookAtViewController(command: Commands) -> LookAtActionViewController {
		return self.viewController(type: LookAtActionViewController.self, command: command)
	}
	
	fileprivate func sayViewController(command: Commands) -> SayViewController {
		return self.viewController(type: SayViewController.self, command: command)
	}

    fileprivate func photoViewController(command: Commands, robot: Robot?) -> PhotoViewController {
        let photo = self.viewController(type: PhotoViewController.self, command: command)
        photo.robot = robot
        return photo
    }

    fileprivate func displayViewController(command: Commands) -> DisplayViewController {
        let display = self.viewController(type: DisplayViewController.self, command: command)
        return display
    }

    fileprivate func motionViewController(command: Commands) -> MotionViewController {
        let motion = self.viewController(type: MotionViewController.self, command: command)
        return motion
    }

    fileprivate func listenViewController(command: Commands) -> ListenViewController {
        let listen = self.viewController(type: ListenViewController.self, command: command)
        return listen
    }

    fileprivate func headTouchViewController(command: Commands) -> HeadTouchViewController {
        let headTouch = self.viewController(type: HeadTouchViewController.self, command: command)
        return headTouch
    }
    
    fileprivate func fetchAssetViewController(command: Commands) -> FetchAssetViewController {
        let fetchAsset = self.viewController(type: FetchAssetViewController.self, command: command)
        return fetchAsset
    }
    
    fileprivate func screenGestureViewController(command: Commands) -> ScreenGestureViewController {
        let screenGesture = self.viewController(type: ScreenGestureViewController.self, command: command)
        return screenGesture
    }
    

}
