//
//  EntityRequestToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/10/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class EntityRequestToken: CommandToken<EntityRequest, Never> {
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
                    let info = TrackedEntityInfo(type: eventBody.event)
                    info.error = err
                    callback?(info, nil)
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
            case .trackUpdate,
                 .trackLost,
                 .trackGained:
                let info = TrackedEntityInfo(type: eventBody.event)
                if let evt = eventBody as? EntityEvent {
                    info.tracks = evt.tracks
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
