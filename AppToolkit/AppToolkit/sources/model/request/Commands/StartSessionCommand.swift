//
//  StartSessionCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class StartSessionCommand: Command {
	
	required init?(map: Map) {
		super.init(map: map)
		
		self.type = .startSession
	}
}
