//
//  CancelCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class CancelCommand: Command {
	var transactionId: String?
	
	required init?(map: Map) {
		super.init(map: map)
		
		self.type = .cancel
	}
	
	convenience init?(transactionId: String) {
		self.init(map: Map(mappingType: .fromJSON, JSON: [:]))
		
		self.transactionId = transactionId
	}
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		
		self.transactionId 	<- map["ID"]
	}
}
