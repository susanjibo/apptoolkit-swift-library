//
//  TakePhotoToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/10/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class TakePhotoToken: CommandToken<TakePhotoCommand, Never> {
    
    override init(_ command: TakePhotoCommand, transactionId: TransactionID?) {
        super.init(command, transactionId: transactionId)
    }
    
    /**
     * Overrides super implementation
     */
    override func emitValue(_ value: Never) {
        super.emitValue(value)
    }

    override func handleEvent(_ data: EventMessage) {
        if isValidEvent(data), let eventBody = data.body, let photo = eventBody as? TakePhotoEvent {
            let info = TakePhotoInfoInternal()
            info.uri = photo.uri
            info.name = photo.name
            info.positionTarget = photo.positionTarget
            info.angleTarget = photo.angleVector
            self.callback?(info, nil)
        } else {
            self.callback?(nil, ErrorResponse(CommandError.badEvent))
        }
    }
}
