//
//  StartSessionToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class StartSessionToken: CommandToken<StartSessionCommand, StartSessionResponse> {
    
    override func emitValue(_ value: StartSessionResponse) {
        super.emitValue(value)
        
        // Set complete after aknowledgment is received
        self.isComplete = true
    }
}

