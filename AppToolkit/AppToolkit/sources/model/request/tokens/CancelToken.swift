//
//  CancelToken.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/8/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class CancelToken: CommandToken<CancelCommand, CancelResponse> {
    
    override init(_ command: CancelCommand, transactionId: TransactionID?) {
        super.init(command, transactionId: transactionId)
    }
	
	override func emitValue(_ value: CancelResponse) {
		super.emitValue(value)
		
		self.isComplete = true
	}
	
}
