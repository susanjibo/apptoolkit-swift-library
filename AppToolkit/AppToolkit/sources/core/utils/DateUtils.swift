//
//  DateUtils.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/25/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class DateUtils {
	
	static let defaultDateFormat = "dd MMM yyyy HH:mm:ss +zzzz"
	
	static func dateToString(date: Date, dateFormat: String = DateUtils.defaultDateFormat)  -> String {
		let dateFormatter = DateUtils.dateFormmater(with: dateFormat)
		
		return dateFormatter.string(from: date)
	}
	
	static func dateFromString(stringDate: String, dateFormat: String = DateUtils.defaultDateFormat) -> Date? {
		let dateFormatter = DateUtils.dateFormmater(with: dateFormat)
		
		return dateFormatter.date(from: stringDate)
	}
	
	fileprivate static func dateFormmater(with dateFormat: String) -> DateFormatter {
		let dateFormatter: DateFormatter = DateFormatter()
		dateFormatter.dateFormat = dateFormat
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		
		return dateFormatter
	}
}
