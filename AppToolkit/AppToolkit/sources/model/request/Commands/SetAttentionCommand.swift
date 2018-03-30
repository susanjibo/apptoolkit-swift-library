//
//  SetAttentionCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class SetAttentionCommand: Command {
	var mode: AttentionMode?
	
    required init?(map: Map) {
		super.init(map: map)
		
		self.type = .setAttention
	}
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		
		mode <- map["Mode"]
	}
}
