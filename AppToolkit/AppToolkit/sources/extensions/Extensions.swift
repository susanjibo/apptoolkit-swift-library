//
//  Extensions.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/9/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: - UInt
/// :nodoc:
public extension UInt {
	public func secondToMicroSeconds() -> UInt {
		return self * 1000
	}
}

// MARK: - NSEror
/// :nodoc:
extension NSError {
	convenience init(code: Int, userInfo: [AnyHashable: Any]) {
		self.init(domain: "com.jibo.rom", code: code, userInfo: userInfo)
	}
}

// MARK: - Map
/// :nodoc:
extension Map {
	subscript<T>(raw: T) -> Map where T: RawRepresentable, T.RawValue == String {
		return self[raw.rawValue]
	}
}

/// :nodoc:
extension Dictionary {
    subscript<T>(key: T) -> Value? where T: RawRepresentable, T.RawValue == String {
        get {
            let k = key.rawValue as! Key
            return self[k]
        }
        set {
            let k = key.rawValue as! Key
            self[k] = newValue
        }
    }
}

// MARK: - Data
/// :nodoc:
extension Data {
	func jsonObject<T>(type: T.Type) -> T? {
		guard let json = try? JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments) as? T else {
			return nil
		}
		return json
	}
}

/// :nodoc:
extension Date {
	func secondsPast(from date: Date) -> TimeInterval {
		let calendar = Calendar.current as NSCalendar
		let components = calendar.components(.second, from: self, to: date, options: [])
		return TimeInterval(components.second!)
	}
}

// MARK: - Date + Token
/// :nodoc:
extension Date {
	func isTokenTTLValid() -> Bool {
		return self.secondsPast(from: Date()) < TokenConstants.tokenTTL
	}
}

/// :nodoc:
extension TimeInterval {
	
	func hourToSeconds() -> TimeInterval {
		return self * 3600
	}
	
	func secondToMicroSeconds() -> TimeInterval {
		return self * 1000
	}
	
	func minuteToSeconds() -> TimeInterval {
		return self * 60
	}
}
