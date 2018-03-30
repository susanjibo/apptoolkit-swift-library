//
//  DisplayToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class DisplayToken: CommandToken<DisplayCommand, Never> {

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
                    let info = DisplayInfo()
                    info.error = err
                    callback?(info, nil)
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
            case .viewStateChange:
                let info = DisplayInfo()
                if let evt = eventBody as? DisplayViewStateEvent, let state = evt.state {
                    info.state = state
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
