//
//  CancelResponse.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class CancelResponse: AcknowledgementBody {
	var cancelledTransactionId: String?
	
	override func mapping(map: Map) {
		super.mapping(map: map)
		
		cancelledTransactionId	<- map["ResponseBody"]
	}
}
