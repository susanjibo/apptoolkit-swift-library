//
//  Environment.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/17/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

/** 
 :nodoc: 
 */
public enum Environment: String {
    case production
    case staging
    case development
    case preprod
    case custom
}

//MARK: - Configuration
/// :nodoc:
struct Configuration: Equatable {
    fileprivate var baseUrl: String?
    var name: String?
    var redirectURI: String?
    var environment: Environment

    init(_ configuration: String) {
        if let env = Environment(rawValue: configuration) {
            environment = env
        } else {
            environment = .custom
        }
        
        if let params = configurationParams(configuration) {
            name        = params["name"] as? String
            baseUrl     = params["baseUrl"] as? String
            redirectURI = params["redirectURI"] as? String
        }
    }

    private func configurationParams(_ name: String) -> Dictionary<String, Any>? {
        switch environment {
        case .custom:
            return customConfigurationParams(name)
        default:
            return defaultConfigurationParams(name)
        }
    }
    
    private func defaultConfigurationParams(_ name: String) -> Dictionary<String, Any>? {
        if let plistPath = Bundle(for: EnvironmentSwitcher.self).path(forResource: name, ofType: "plist", inDirectory: "environments") {
            return NSDictionary(contentsOfFile: plistPath) as? Dictionary<String, Any>
        } else if let plistPath = Bundle(for: EnvironmentSwitcher.self).path(forResource: name, ofType: "plist") {
            return NSDictionary(contentsOfFile: plistPath) as? Dictionary<String, Any>
        }

        return nil
    }

    private func customConfigurationParams(_ name: String) -> Dictionary<String, Any>? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, [.userDomainMask], true)[0]
        let environmentsPath = (documentsPath as NSString).appendingPathComponent("/environments")
        createEnvironmentsDirectoryIfNeeded(environmentsPath)

        if let plistPath = Bundle(for: EnvironmentSwitcher.self).path(forResource: name, ofType: "plist", inDirectory: "environments") {
            return NSDictionary(contentsOfFile: plistPath) as? Dictionary<String, Any>
        } else if let plistPath = Bundle(for: EnvironmentSwitcher.self).path(forResource: name, ofType: "plist") {
            return NSDictionary(contentsOfFile: plistPath) as? Dictionary<String, Any>
        }
        
        return nil
    }

    private func createEnvironmentsDirectoryIfNeeded(_ path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false)
        }
    }
    
    static func ==(lhs: Configuration, rhs: Configuration) -> Bool {
        return lhs.name == rhs.name
    }
}

/// :nodoc:
extension Configuration {
    var authUrl: String? {
        guard let url = baseUrl else { return nil }

        return url + "/login"
    }

    var tokenUrl: String? {
        guard let url = baseUrl else { return nil }
        
        return url + "/token"
    }

    var userInfoUrl: String? {
        guard let url = baseUrl else { return nil }
        
        return url + "/rom/v1/info"
    }

    var robotsListUrl: String? {
        guard let url = baseUrl else { return nil }
        
        return url + "/rom/v1/robots/"
    }
	
	var certificatesCreationUrl: String? {
		guard let url = baseUrl else { return nil }
		
		return url + "/rom/v1/certificates/"
	}
	
	var certificatesRetrievalUrl: String? {
		guard let url = baseUrl else { return nil }
		
		return url + "/rom/v1/certificates/client"
	}
}

//MARK: - Environment switcher
/// :nodoc:
fileprivate let EnvironmentID = "EnvironmentID"

/// :nodoc:
class EnvironmentSwitcher {
    var currentEnvironment: Environment {
        get {
            return currentConfiguration.environment
        }
        set {
            //TODO: add custom configurations creation support
            guard newValue != .custom else { return }

            let configName = newValue.rawValue
            currentConfiguration = Configuration(configName)
            UserDefaults.standard.set(configName, forKey:EnvironmentID)
        }
    }
    var currentConfiguration: Configuration

    class func shared() -> EnvironmentSwitcher {
        return sharedEnvironmentSwitcher
    }

    private static var sharedEnvironmentSwitcher: EnvironmentSwitcher = {
        let switcher = EnvironmentSwitcher()
        
        return switcher
    }()

    private init() {
        if let env = UserDefaults.standard.string(forKey: EnvironmentID) {
            currentConfiguration = Configuration(env)
        } else {
            currentConfiguration = Configuration(Environment.staging.rawValue)
        }
    }
}
