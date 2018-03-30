//
//  MotionToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class MotionToken: CommandToken<MotionRequest, Never> {

    /**
     * Overrides super implementation
     */
    override func handleEvent(_ data: EventMessage) {
        if isValidEvent(data), let eventBody = data.body {
            switch eventBody.event {
            case .asyncStop:
                emitValue(Never())
            case .asyncError:
                if let evt = eventBody as? AsyncErrorEvent, let err = evt.eventError {
                    let info = MotionInfo()
                    info.error = err
                    callback?(info, nil)
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
            case .motionDetected:
                let info = MotionInfo()
                if let evt = eventBody as? MotionEvent {
                    info.motions = evt.motions
                }
                callback?(info, nil)
                
            default:
                print("Wrong event!!! \(eventBody)")
                break
            }
        } else {
            callback?(nil, ErrorResponse(CommandError.badEvent))
        }
    }
}
