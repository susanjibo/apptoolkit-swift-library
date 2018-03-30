//
//  AuthManager.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/17/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import PromiseKit
import ReactiveSwift
import SafariServices
import ObjectMapper
import Alamofire
import Reachability

enum AuthState {
	case undefined
	case authorized
	// Token is missed or already expired
	case authorizedButTokenMissed
	// Certificate(s) are missed or not valid
	case authorizedButCertMissed
	case notAuthorized
}

// MARK: - AuthManagerProtocol
protocol AuthManagerProtocol {
    var isAuthenticated: Bool { get }
	
	var authState: AuthState { get }
	
    func authenticate() -> Promise<Bool>
    func getIpAddress(robot: RobotInfoProtocol) -> Promise<Robot?>
    func invalidate()
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool

    func authorizer() -> RequestAuthorizer
	func refreshToken(clientInfo: ClientInfo) -> Promise<Bool>

    func certificate(for robot: Robot) -> Promise<CertificateInfo>
}

final class RequestAuthorizer {
    private var token: Token? = nil

    init(_ token: Token?) {
        updateToken(token: token)
    }
    
    func authorize(request: URLRequest) -> URLRequest {
        guard let token = token else { return request }
        
        do {
            var urlRequest = try request.asURLRequest()
            let authHeader = ["Authorization": "\(token.type.asAuthParameter()) \(token.accessToken)"]
            urlRequest.allHTTPHeaderFields = authHeader
            return urlRequest
        } catch {
            print("Failed to auth request \(request)")
            return request
        }
    }
    
    func updateToken(token: Token?) {
        self.token = token
    }
}

// MARK: - ClientInfo
struct ClientInfo: Mappable {
	
	enum Keys: String {
		case root = "JiboSDK"
		case id = "ClientID"
		case secret = "ClientSecret"
	}
	
	var clientID: String = ""
	var clientSecret: String = ""
	
	init?(map: Map) { }
	
	mutating func mapping(map: Map) {
		clientID 		<- map[Keys.id]
		clientSecret 	<- map[Keys.secret]
	}
	
	static func makeInfo() -> ClientInfo? {
		guard let infoDictionary = Bundle.main.infoDictionary else {
			print("Cannot load Bundle.main.infoDictionary")
			return nil
		}
		guard let sdkInfo = infoDictionary[Keys.root.rawValue] as? [String: Any] else {
			print("Cannot load Dictionary under %@ key", Keys.root.rawValue)
			return nil
		}
		
		guard let clientInfo = ClientInfo(JSON: sdkInfo) else {
			return nil
		}
		
		if !clientInfo.isValidClientID() {
			print("%@ value cannot be empty", Keys.id.rawValue)
			return nil
		}
		
		return clientInfo
	}
	
	func isValidClientID() -> Bool {
		return !clientID.isEmpty
	}
}

// MARK: - AuthInfo
struct AuthInfo {
    fileprivate var antiForgeryToken: String? = nil
    fileprivate var authorizationCode = MutableProperty(nil as String?)
    fileprivate var error: Error? {
        didSet {
            authorizationCode.value = "-1001"
        }
    }

    mutating func cleanup() {
        error = nil
        antiForgeryToken = nil
        authorizationCode.value = nil
    }
}

// MARK: - AuthManager
class AuthManager: AuthManagerProtocol {
    var isAuthenticated: Bool { return authState != .undefined && authState != .notAuthorized }
	var authState: AuthState {
        guard !CommandLibrary.useSimulator else {
            // always authorize for simulator flow
            return .authorized
        }

		guard let token = KeychainUtils.obtainOrRemoveTokenIfNotValid() else {
			return .notAuthorized
		}
		
		if !token.isTTLValid() {
			return .authorizedButTokenMissed
		}
		
		return .authorized
	}
	
	private var isAuthorizing: Bool = false // prevent simultaneoous autorization
    private lazy var authInfo: AuthInfo = AuthInfo()
	fileprivate lazy var clientInfo = ClientInfo.makeInfo()
	fileprivate lazy var oauthService: OAuthService = {
		return OAuthService(executor: requestExecutor)
	}()
    private var poller: CertificatePoller?
    private lazy var simulatorCert: CertificateInfo = {
        // use predefined certificate for simulator flow
        var info = CertificateInfo()!
        info.cert = jiboCert
        return info
    }()

    init() {
        KeychainUtils.obtainOrRemoveTokenIfNotValid()
    }
    
	// TODO: throw some error on clientInfo nil?
    func authenticate() -> Promise<Bool> {
        guard let clientInfo = clientInfo,
			!isAuthorizing else { return Promise(value: false) }
		
        // 1. make cleanup
        authInfo.cleanup()
        isAuthorizing = true
        return Promise { [unowned self] (fulfill, reject) in
            // 2. Obtain OAuth code for token exchange
            self.obtainAuthCode(clientID: clientInfo.clientID)
				.then { [unowned self] (authCode) -> () in
					
					guard let authCode = authCode else {
						fulfill(false)
						return
					}
                    // 3. Obtain token
					self.obtainToken(authCode: authCode,
					                 clientInfo: clientInfo) { [unowned self] result in
										self.isAuthorizing = false
                                        switch result {
                                        case .failure(let error):
                                            reject(error)
                                        case .success(let success):
                                            fulfill(success)
                                        }
					}
                }
                .catch { [unowned self] (e) in
                    self.isAuthorizing = false
                    reject(e)
				}
        }
    }
    
    // One of very first calls to setup robot connection
    func getIpAddress(robot: RobotInfoProtocol) -> Promise<Robot?> {
        return Promise { [unowned self] (fulfill, reject) in
            // 1. make cleanup
            KeychainUtils.removeCertificate(for: robot.robotName!)
            let service = CertificateService(executor: requestExecutor)
            
            // 2. Deploy certificate to the robot
            service.createCertificate(for: robot.robotName!, authorizer: self.authorizer(), completion: { [unowned self] (info, error) in
                if let error = error {
                    print("Certificate create for \(robot.name!) failed: \(error)")
                    reject(ApiError.certificateCreateError)
                } else {
                    print("Certificate create succeed: \(info!)")
                    
                    // 3. Start polling for getting robot info.
                    // Ususally it takes up to 5 seconds to deploy certificate to robot and return proper robot info
                    self.poller = CertificatePoller(Robot(ip: "", port:0, info: robot), authorizer: self.authorizer())
                    self.poller?.pollingComplete.producer
                        .skipRepeats({ (s1, s2) -> Bool in
                            return s1 == s2
                        })
                        .on(value: { [unowned self] value in
                            guard let poller = self.poller, poller.pollingStarted else { return }
                            
                            if value,
                                let certInfo = self.poller?.certificate,
                                let ipAddress = certInfo.getIpAddress() {
                                
                                // 4. On success store client certificate and populate robot info
                                KeychainUtils.saveCertificate(certInfo, for: robot.robotName!)
                                let newRobot = Robot(ip: ipAddress, port: 7160, info: robot)
                                fulfill(newRobot)
                            } else {
                                reject(ApiError.certificateFetchError)
                            }
                            self.poller = nil
                        })
                        .take(duringLifetimeOf: self.poller!)
                        .start()
                    self.poller?.fetchCertificate()
                }
            })
        }
    }

    func invalidate() {
        KeychainUtils.removeToken()
        KeychainUtils.removeCertificates()
    }

    // OAuth authentication redirection handler
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        guard isAuthorizing else { return false }
        
        switch url.flavor() {
        case .redirectForLogin(let code, let state):
            if state == authInfo.antiForgeryToken {
                authInfo.authorizationCode.value = code
            }
        case .accessDenied(let error):
            authInfo.error = error
        case .undefined:
            return false
        }

        return true
    }
    
    //MARK: - Private
    internal func authorizer() -> RequestAuthorizer {
        return RequestAuthorizer(KeychainUtils.obtainOrRemoveTokenIfNotValid())
    }
    
    internal func certificate(for robot: Robot) -> Promise<CertificateInfo> {
        guard !CommandLibrary.useSimulator else { return Promise<CertificateInfo>(value: simulatorCert) }
        
        return Promise { (fulfill, reject) in
            if let robotName = robot.info.robotName,
                let certificate = KeychainUtils.getCertificate(for: robotName) {
                fulfill(certificate)
            } else {
                reject(ApiError.certificateFetchError)
            }
        }
    }

    // Open Web view internally to allow to pass login/password
    private func obtainAuthCode(clientID: String) -> Promise<String?> {
        if let topVC = UIViewController.topViewController() {
			let (state, request) = oauthService.loginRequestBundle(clientID: clientID)
			guard let urlRequest = request else { return Promise<String?>(value: nil)  }
            authInfo.antiForgeryToken = state
			
            let (promise, fulfill, reject) = Promise<String?>.pending()
            let authViewController = AuthViewController(urlRequest, handleDismissal: reject)
            authViewController.modalPresentationStyle = .overFullScreen
            topVC.present(authViewController, animated: true, completion: { [unowned self] in
                self.authInfo.authorizationCode
                    .producer
                    .skipRepeats({ (s1, s2) -> Bool in
                        return s1 == s2
                    })
                    .on(value: { value in
                        if let value = value {
                            authViewController.dismiss(animated: true, completion: nil)
                            if let error = self.authInfo.error {
                                reject(error)
                            } else {
                                fulfill(value)
                            }
                        }
                    })
                    .take(until: authViewController.viewWillDisappearSignalProducer)
                    .start()
            })
            return promise
        }

        return Promise<String?>(value: nil)
    }
}

// MARK: - AuthManager + Token
extension AuthManager {
	
	fileprivate func obtainToken(authCode: String, clientInfo: ClientInfo, completion: @escaping (Alamofire.Result<Bool>) -> ()) {
		oauthService.obtainToken(code: authCode, clientInfo: clientInfo, completion: completion)
	}
	
	func refreshToken(clientInfo: ClientInfo) -> Promise<Bool> {
		return Promise { (fulfill, reject) in
			oauthService.refreshToken(clientInfo: clientInfo) { result in
				switch result {
                case (.success(let succeeded), _):
					fulfill(succeeded)
                case (.failure(let error), _):
					reject(error)
				}
			}
		}
	}
}

// MARK: - AuthViewController
class AuthViewController: UIViewController {
    private var request: URLRequest
    fileprivate var safariViewController: SFSafariViewController
    fileprivate var handleDismissal: ((Error) -> ())
    private let reachability = Reachability()!

    init(_ request: URLRequest, handleDismissal: ((Error) -> ())!) {
        self.request = request
        self.handleDismissal = handleDismissal
        safariViewController = SFSafariViewController(url: request.url!)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configReachability()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        safariViewController.view.frame = self.view.frame
    }

    private func configUI() {
        addChildViewController(safariViewController)
        self.view.addSubview(safariViewController.view)
        safariViewController.delegate = self
    }
    
    private func configReachability() {
        reachability.allowsCellularConnection = false
        reachability.whenUnreachable = { [unowned self] _ in
            // dismiss auth webview on connection loss
            print("No internet connection, closing...")
            self.handleDismissal(ApiError.noInternet)
            self.dismiss(animated: true, completion: nil)
        }
        
        reachability.whenReachable = { reachability in
            if reachability.connection != .wifi {
                // dismiss auth webview on connection loss
                print("No internet connection, closing...")
                self.handleDismissal(ApiError.noInternet)
                self.dismiss(animated: true, completion: nil)
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Failed to start reachability...")
        }

    }
}

// MARK: - AuthViewController: SFSafariViewControllerDelegate
extension AuthViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        handleDismissal(ApiError.notAuthorized)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Polling for certificate
fileprivate class CertificatePoller {
    fileprivate var certificate: CertificateInfo?
    fileprivate var pollingComplete = MutableProperty<Bool>(false)
    fileprivate var pollingStarted: Bool {
        return retryCount > 0
    }

    private var robot: Robot
    private var authorizer: RequestAuthorizer
    private let maxRetryCount = 30
    private var retryCount = 0

    init(_ robot: Robot, authorizer: RequestAuthorizer) {
        self.robot = robot
        self.authorizer = authorizer
    }
    
    func fetchCertificate() {
        retryCount = retryCount + 1
        guard retryCount < maxRetryCount else {
            print("Polling is stopped")
            pollingComplete.value = true
            return
        }
        
        let service = CertificateService(executor: requestExecutor)
        service.retrieveCertificate(for: robot.info.robotName!, authorizer: authorizer, completion: { [weak self] (info, error) in
            guard let me = self else { return }
            
            if error != nil {
                // Fetch certificate one more time
                print("Certificate retrieval for \(me.robot.info.name!) failed: \(error!)")
                print("Trying to fetch again [\(me.retryCount)]...")

                let deadline = DispatchTime.now() + 1
                DispatchQueue.global().asyncAfter(deadline: deadline, execute: { [weak self] in
                    guard let me = self else { return }
                    
                    me.fetchCertificate()
                })
            } else {
                if let info = info as? CertificateInfo {
                    print("Certificate retrieval succeed: \(info)")
                    me.certificate = info
                }
                
                // Triggers polling completion
                me.pollingComplete.value = true
            }
        })
    }
}
