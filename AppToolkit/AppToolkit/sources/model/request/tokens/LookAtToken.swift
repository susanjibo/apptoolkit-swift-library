//
//  LookAtToken.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/9/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class LookAtToken: CommandToken<LookAtCommand, Never> {
	
	override init(_ command: LookAtCommand, transactionId: TransactionID?) {
		super.init(command, transactionId: transactionId)
	}
	

	override func emitValue(_ value: Never) {
        super.emitValue(value)
	}
    
    override func handleEvent(_ data: EventMessage) {
        if isValidEvent(data), let eventBody = data.body, let look = eventBody as? LookAtEvent {
            let info = LookAtAchievedInfo()
            info.angleTarget = look.angleTarget
            info.positionTarget = look.positionTarget
            info.type = look.event
            self.callback?(info, nil)
        } else {
            self.callback?(nil, ErrorResponse(CommandError.badEvent))
        }
    }
}
