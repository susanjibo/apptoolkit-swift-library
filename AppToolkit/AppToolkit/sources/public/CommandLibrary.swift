//
//  CommandLibrary.swift
//  AppToolkit
//
//  Created by Calvin Park on 9/28/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

//MARK: Robot Info
/**
 Information for the robot we're connecting to.
 - Parameters:
    - info: See `RobotInfoProtocol`.
    - ip: Robot's IP address.
    - port: Robot's port number.
 */
public struct Robot {
    let info: RobotInfoProtocol
    let ip: String
    let port: Int

    /// :nodoc:
    public init(ip: String, port: Int, info: RobotInfoProtocol) {
        self.ip = ip
        self.port = port
        self.info = info
    }
    /// :nodoc:
    public func getIp() -> String? {
        return ip
    }
    /// :nodoc:
    public func getPort() -> Int {
        return port
    }
    /// :nodoc:
    public func getName() -> String? {
        return info.name  
    }
    /// :nodoc:
    public func getRobotName() -> String? {
        return info.robotName
    }
}

//MARK: Main Library
/**
 Main library for the Jibo Protocol
 */
public protocol CommandLibraryInterface {
    // MARK: - Handler
    /// Completion handler
    typealias CompletionHandler = ((Bool, Error?) -> ())
    /// :nodoc:
    typealias ConnectionStateChangeHandler = ((Bool, Error?) -> ())

    // MARK: - Connectivity
    /// :nodoc:
    var onConnectionStateChange: ConnectionStateChangeHandler? { get set }

    /**
     `true` if the robot has been successfully authenticated. 
     */
    var isAuthenticated: Bool { get }

    /**
     Authenticate with Jibo cloud. This function will prompt users to 
     sign into their Jibo account with their email and password. Once they have 
     authenticated their account, they will be able to connect their robot to your app.
     */
    func authenticate(completion: @escaping CompletionHandler)

    /**
     Remove authentication for the account. Users will have to authenticate again
     to connect to your app.
     */
    func invalidate(completion: @escaping CompletionHandler)
    
    /**
     Get a list of all robots associated with the user's authenticated account. 
     It is suggested that you prompt users to select which robot they would 
     like to connect to use your app in the event that they own multiple robots.
     */
    func getRobotsList(completion: RobotListClosure?)
    @available(*, deprecated: 0.0.4, message: "Use invalidate(completion:)")
    
    /**
     Get the IP address of the robot you want to connect to.
     - Parameters:
        - robot: The robot to get the IP address for
        - completion: `RobotClosure`
     */
    func getIpAddress(robot: RobotInfoProtocol, completion: RobotClosure?)

    /** 
     Connect to a robot. Can only be called for robots where `isAuthenticated = true`
     - Parameters:
        - robot: `your-friendly-robot-name.local` See underside of robot base for name.
        - completion: `CompletionHandler`
     */
    func connect(robot: Robot, completion: CompletionHandler?)

    /**
     Disconnect from the currently connected robot.
     */
    func disconnect(completion: CompletionHandler?)

    // MARK: Commands
    /**
     Get robot configuration data.
     */
    func getConfiguration(completion: GetConfigClosure?) -> TransactionID?

    /**
     Set robot configuration data.
     - Parameters:
        - options: `SetConfigOptionsProtocol`
        - completion: `SetConfigClosure`
     */
    func setConfiguration(_ options: SetConfigOptionsProtocol, completion: SetConfigClosure?) -> TransactionID?
    /**
     Make Jibo speak.
     - Parameters:
        - phrase: What Jibo should say. Can take plain text or [ESML](https://app-toolkit.jibo.com/esml.html#esml).
        - completion: `SayClosure`
    */
    func say(phrase: String, completion: SayClosure?) -> TransactionID?

    /**
     Cancel a transaction.
     - Parameters:
         - transactionId: ID of the transaction to cancel.
         - completion: `CompletionHandler`
     */
    func cancel(transactionId: TransactionID, completion: CompletionHandler?)

    /**
     Make Jibo look toward a specific spot.
     - Parameters:
        - targetType: Where to make Jibo look. See `LookAtTargetType`
        - trackFlag: Unsupported. Use `false`.
        - levelHeadFlag: `true` to keep Jibo's head level while he moves.
        - completion: `LookAtClosure`
     */
    func lookAt(targetType: LookAtTargetType, trackFlag: Bool, levelHeadFlag: Bool, completion: LookAtClosure?) -> TransactionID?
    
    /**
     Get a stream of what Jibo's cameras see.
     - Parameters:
        - videoType: Use `normal`. `debug` not currently supported.
        - duration: Unsupported. Call `cancel()` to stop the stream.
        - completion: `TakeVideoClosure`
     */
    func takeVideo(videoType: VideoType, duration: TimeInterval, completion: TakeVideoClosure?) -> TransactionID?
    
    /**
     Take a photo.
     - Parameters:
        - camera: `left` or `right` camera to take photo with. Only `left` is supported at this time.
        - resolution: Choose a `CameraResolution`. Default = `low`.
        - distortion: `true` for regular lense. `false` for fisheye lense. 
        - completion: `TakePhotoClosure`
     */
    func takePhoto(camera: Camera, resolution: CameraResolution, distortion: Bool, completion: TakePhotoClosure?) -> TransactionID?
    
    /**
     Get a face to track. Currently unsupported.
     */
    func getFaceEntity(completion: TrackedEntityClosure?) -> TransactionID?
 
    /**
     Display Jibo's eye on screen.
     - Parameters:
        - view: Unique name of view.
        - completion: `DisplayClosure`
     */
    func displayEye(in view: String, completion: DisplayClosure?) -> TransactionID?

    /**
     Display text on screen.
     - Parameters:
        - text: text to display.
        - view: Unique name of view.
        - completion: `DisplayClosure`
     */
    func displayText(_ text: String, in view: String, completion: DisplayClosure?) -> TransactionID?
    
    /**
     Display an image on screen.
     - Parameters:
        - image: Info for the image to display
        - view: Unique name of view.
        - completion: `DisplayClosure`
     */
    func displayImage(_ image: ImageData, in view: String, completion: DisplayClosure?) -> TransactionID?

    /**
     Track motion in Jibo's perceptual space.
     */
    func getMotion(completion: MotionClosure?) -> TransactionID?

    /**
     Listen for speech input.
     - Parameters:
         - maxSpeechTimeOut: [default = 15] In seconds
         - maxNoSpeechTimeout: [default = 15] In seconds
         - languageCode: [default = `en_US`] Language code. Only English is supported.
         - completion: `ListenClosure`
     */
    func listenForSpeech(maxSpeechTimeOut: Timeout, maxNoSpeechTimeout: Timeout, languageCode: LangCode, completion: ListenClosure?) -> TransactionID?

    /**
     Listen for head touch.
     */
    func listenForHeadTouch(completion: HeadTouchClosure?) -> TransactionID?

    /**
     Retrieve external asset and store in local cache by name.
     - Parameters:
        - uri: URI to the asset to be fetched.
        - name: Name the asset will be called by.
        - completion: `FetchAssetClosure`
     */
    func fetchAssetWithURI(_ uri: String, name: String, completion: FetchAssetClosure?) -> TransactionID?

    /**
     Listen for screen gesture.
     - Parameters:
        - params: `ScreenGestureListenParams`
        - completion: `ScreenGestureClosure`
     */
    func listenForScreenGesture(_ params: ScreenGestureListenParams, completion: ScreenGestureClosure?) -> TransactionID?

    /**
     Turn on Jibo Simulator flow. Default value is `false`.

     Use `CommandLibrary.useSimulator = false` in `viewDidLoad()`
     */
    static var useSimulator: Bool { get set }
}

/**
 :nodoc:
 */
public class CommandLibrary: CommandLibraryInterface {
    // MARK: - Connection state
	public var onConnectionStateChange: ConnectionStateChangeHandler? {
		didSet {
			self.connectionPolicyManager.onConnectionStateChange = self.onConnectionStateChange
		}
	}

    // MARK: - Private Variables
	internal var requester: CommandRequester? {
		return self.connectionPolicyManager.requester
	}
	fileprivate var connectionManager: ConnectivityManager? {
		return self.connectionPolicyManager.connectionManager
	}
    fileprivate lazy var authManager: AuthManagerProtocol = AuthManager()
    fileprivate lazy var executor: RequestExecutor = requestExecutor
	
	fileprivate lazy var connectionPolicyManager: ConnectionPolicyManagerProtocol = {
		return ConnectionPolicyManager(authManager: self.authManager)
	}()
    fileprivate var videoFetcher: CommandVideoFetcher? = nil
    fileprivate var photoFetcher: CommandPhotoFetcher? = nil
    
    private lazy var simulatedRobotInfo: RobotInfoProtocol = {
        struct SimulatedRobotInfo: RobotInfoProtocol {
            var id: String? = "simulatedRobot"
            var name: String? = "simulatedRobotName"
            var robotName: String? = "ImmaLittleTeapot"
        }
        return SimulatedRobotInfo()
    }()
    
    private lazy var simulatedRobot: Robot = {
        let robot = Robot(ip: "127.0.0.1", port: 8160, info: self.simulatedRobotInfo)
        return robot
    }()

    // MARK: Public interface

    public required init() { }

    public var isAuthenticated: Bool { return authManager.isAuthenticated }

    public func authenticate(completion: @escaping CompletionHandler) {
		self.connectionPolicyManager.authenticate(completion: completion)
    }
    
    public func getIpAddress(robot: RobotInfoProtocol, completion: RobotClosure?) {
        guard !CommandLibrary.useSimulator else {
            // use predefined robot for simulator flow
            completion?(simulatedRobot, nil)
            return
        }

        authManager.getIpAddress(robot: robot)
            .then { robot -> () in
                completion?(robot, nil)
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
    }

    public func invalidate(completion: @escaping CompletionHandler) {
        self.connectionPolicyManager.invalidate(completion: completion)
    }

    public func connect(robot: Robot, completion: CompletionHandler? = nil) {
        let robot = CommandLibrary.useSimulator ? simulatedRobot : robot

        self.connectionPolicyManager.connect(robot: robot, completion: completion)
    }
    
    public func disconnect(completion: CompletionHandler? = nil) {
        self.connectionPolicyManager.disconnect(completion: completion)
    }
    
    public func getConfiguration(completion: GetConfigClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.getConfig(genericCallback.execute)
        
        command?.tokenAcknowledged.then { _ in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }
	
    public func setConfiguration(_ options: SetConfigOptionsProtocol, completion: SetConfigClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.setConfig(options, callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { _ in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }

	public func say(phrase: String, completion: SayClosure?) -> TransactionID? {
		let genericCallback = Callback(callback: completion)
        let command = requester?.say(phrase: phrase, callback: genericCallback.execute)

        command?.tokenAcknowledged.then { _ in
            completion?(nil, nil)
        }.catch { error in
            completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
	}

    public func lookAt(targetType: LookAtTargetType,
                       trackFlag: Bool,
                       levelHeadFlag: Bool,
                       completion: LookAtClosure?) -> TransactionID? {

        let genericCallback = Callback(callback: completion)
        let command = requester?.lookAt(targetType: targetType, trackFlag: trackFlag, levelHeadFlag: levelHeadFlag, callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            completion?(nil, nil)
        }.catch { error in
            completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }
    
	public func takeVideo(videoType: VideoType = .normal,
                          duration: TimeInterval,
                          completion: TakeVideoClosure?) -> TransactionID? {

        let closure: ((URIBasedInfo?, ErrorResponse?) -> ()) = { [weak self] (value, error) in
            guard let sself = self, let robot = sself.connectionPolicyManager.currentRobot, let video = value, let uri = video.uri else {
                completion?(nil, error)
                return
            }
            // Use separate instance (with additional security handling) to get media
            sself.authManager.certificate(for: robot).then { (certificate) -> () in
                let schema = CommandLibrary.useSimulator ? "http://" : "https://"
                let urlString = "\(schema)\(robot.getIp()!):\(robot.getPort())" + uri
                let fetcher = CommandVideoFetcher(URL(string: urlString)!, certificate: certificate)
                fetcher.didFetchImage = { (image) in
                    completion?(image, nil)
                }

                sself.videoFetcher = fetcher
                fetcher.start()
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
        }
        
        let genericCallback = Callback(callback: closure)
        let command = requester?.takeVideo(videoType: videoType, duration: duration, callback: genericCallback.execute, finalizer: { [weak self] in
            guard let sself = self else { return }
            // cleanup fetcher on exit
            sself.videoFetcher = nil
        })
        
        command?.tokenAcknowledged.then { _ in
            return // no need to handle here, callback is handled separately
        }.catch { error in
            completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
	}
    
    public func takePhoto(camera: Camera,
                          resolution: CameraResolution,
                          distortion: Bool,
                          completion: TakePhotoClosure?) -> TransactionID? {
        
        let closure: ((URIBasedInfo?, ErrorResponse?) -> ()) = { [weak self] (value, error) in
            guard let sself = self, let robot = sself.connectionPolicyManager.currentRobot, let photo = value, let uri = photo.uri else {
                completion?(nil, error)
                return
            }
            // Use separate instance (with additional security handling) to get media
            sself.authManager.certificate(for: robot).then { (certificate) -> () in
                let schema = CommandLibrary.useSimulator ? "http://" : "https://"
                let urlString = "\(schema)\(robot.getIp()!):\(robot.getPort())" + uri
                let fetcher = CommandPhotoFetcher(URL(string: urlString)!, certificate: certificate)
                fetcher.didFetchImage = { (image) in
                    if let info = value as? TakePhotoInfoInternal {
                        let photoInfo = TakePhotoInfo(internal: info)
                        photoInfo.image = image
                        completion?(photoInfo, nil)
                    }
                }
                
                sself.photoFetcher = fetcher
                fetcher.start()
                }.catch { error in
                    completion?(nil, ErrorResponse(error))
            }
        }
        
        let genericCallback = Callback(callback: closure)
        let command = requester?.takePhoto(with: camera, resolution: resolution, distortion: distortion, callback: genericCallback.execute, finalizer: { [weak self] in
            guard let sself = self else { return }
            // cleanup fetcher on exit
            sself.photoFetcher = nil
        })

        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
        }.catch { error in
            completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }
	
    public func getFaceEntity(completion: TrackedEntityClosure? = nil) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.entityRequest(callback: genericCallback.execute)
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
        }.catch { error in
            completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }
    
	public func cancel(transactionId: TransactionID, completion: CompletionHandler? = nil) {
		requester?.cancel(transactionId: transactionId).then { cancel -> () in
			completion?(cancel.cancelledTransactionId != nil, nil)
		}.catch { error in
			completion?(false, error)
		}
    }
    
    public func getRobotsList(completion: RobotListClosure? = nil) {
        guard !CommandLibrary.useSimulator else {
            // use predefined robot for simulator flow
            completion?([simulatedRobotInfo], nil)
            return
        }
		let robotsService = RobotsService(executor: requestExecutor)
		robotsService.obtainRobotsList(authorizer: authManager.authorizer(), completion: completion)
    }
    
    public func displayEye(in view: String, completion: DisplayClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.displayEye(in: view, callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }
    
    public func displayText(_ text: String, in view: String, completion: DisplayClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.displayText(text, in: view, callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }
    
    public func displayImage(_ image: ImageData, in view: String, completion: DisplayClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.displayImage(image, in: view, callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }

    public func getMotion(completion: MotionClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.getMotion(callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }

    public func listenForSpeech(maxSpeechTimeOut: Timeout = 15, maxNoSpeechTimeout: Timeout = 15, languageCode: LangCode = .enUS, completion: ListenClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.listenForSpeech(maxSpeechTimeOut: maxSpeechTimeOut, maxNoSpeechTimeout: maxNoSpeechTimeout, languageCode: languageCode, callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }
    
    public func listenForHeadTouch(completion: HeadTouchClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.listenForHeadTouch(callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }

    public func fetchAssetWithURI(_ uri: String, name: String, completion: FetchAssetClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.fetchAssetWithURI(uri, name: name, callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }

    public func listenForScreenGesture(_ params: ScreenGestureListenParams, completion: ScreenGestureClosure?) -> TransactionID? {
        let genericCallback = Callback(callback: completion)
        let command = requester?.listenForScreenGesture(params, callback: genericCallback.execute)
        
        command?.tokenAcknowledged.then { result in
            return // no need to handle here, callback is handled separately
            }.catch { error in
                completion?(nil, ErrorResponse(error))
        }
        return command?.transactionId
    }
}

/**
 :nodoc:
 */
extension CommandLibrary {
    public static var environment: Environment {
        get {
            return EnvironmentSwitcher.shared().currentEnvironment
        }
        set {
            EnvironmentSwitcher.shared().currentEnvironment = newValue
        }
    }
}

/**
 :nodoc:
 */
extension CommandLibrary {
    public func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        // redirect OAuth callback
        return authManager.application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

/**
 :nodoc:
 */
extension CommandLibrary {
    /**
     for using simulator to test
     */
    public static var useSimulator: Bool {
        get {
            return _useSimulator
        }
        set {
            _useSimulator = newValue
        }
    }

}

private var _useSimulator: Bool = false
