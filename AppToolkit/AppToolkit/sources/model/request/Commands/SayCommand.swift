//
//  SayCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class SayCommand: Command {
	var esml: String?
	
	convenience init?(phrase: String) {
		let map = Map(mappingType: .fromJSON, JSON: [:])
		self.init(map: map)
		
		self.esml = phrase
	}
	
	required init?(map: Map) {
		super.init(map: map)
		
		self.type = .say
	}
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		
		esml <- map["ESML"]
	}
}
