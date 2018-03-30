//
//  SayToken.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/10/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class SayToken: CommandToken<SayCommand, Never> {
	
    override init(_ command: SayCommand, transactionId: TransactionID?) {
		super.init(command, transactionId: transactionId)
	}
	
    override func emitValue(_ value: Never) {
        super.emitValue(value)
    }
	
	override func handleEvent(_ data: EventMessage) {
		if isValidEvent(data), let eventBody = data.body {
				let info = SayCompletedInfo()
				info.type = eventBody.event
				self.callback?(info, nil)
        } else {
            self.callback?(nil, ErrorResponse(CommandError.badEvent))
        }
	}
}
