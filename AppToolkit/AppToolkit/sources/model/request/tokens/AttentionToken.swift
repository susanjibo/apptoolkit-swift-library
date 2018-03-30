//
//  AttentionToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class AttentionToken: CommandToken<SetAttentionCommand, Never> {
    
    override func emitValue(_ value: Never) {
        super.emitValue(value)
        
        self.isComplete = true
    }
}
