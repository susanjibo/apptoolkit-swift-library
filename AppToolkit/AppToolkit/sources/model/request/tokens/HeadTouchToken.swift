//
//  HeadTouchToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class HeadTouchToken: CommandToken<HeadTouchRequest, Never> {
    
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
                    let info = HeadTouchInfo()
                    info.error = err
                    callback?(info, nil)
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
            case .headTouched:
                var info = HeadTouchInfo()
                if let evt = eventBody as? HeadTouchEvent, let pads = evt.pads {
                    info = HeadTouchInfo(pads)
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
