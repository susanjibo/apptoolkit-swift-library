//
//  NSObject+Extension.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

extension NSObject {
	
	class var nameOfClass: String {
		return String(describing: self)
	}
	
}
