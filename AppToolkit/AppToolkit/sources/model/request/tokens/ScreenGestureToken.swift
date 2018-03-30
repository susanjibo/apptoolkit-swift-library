//
//  ScreenGestureToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/14/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

class ScreenGestureToken: CommandToken<ScreenGestureRequest, Never> {
    
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
                    let info = ScreenGestureInfo()
                    info.error = err
                    callback?(info, nil)
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
            case .onScreenTap:
                let info = ScreenGestureInfo()
                info.gesture = ScreenGestureEntity()
                if let evt = eventBody as? ScreenGestureTapEvent, let coordinate = evt.coordinate {
                    info.gesture?.coordinate = evt.coordinate
                    info.gestureType = ScreenGestureInfo.ScreenGestureType.tap(coordinate: coordinate)
                }
                callback?(info, nil)
            case .onScreenSwipe:
                let info = ScreenGestureInfo()
                info.gesture = ScreenGestureEntity()
                if let evt = eventBody as? ScreenGestureSwipeEvent, let direction = evt.direction {
                    info.gesture?.direction = evt.direction
                    info.gesture?.velocity = evt.velocity
                    info.gestureType = ScreenGestureInfo.ScreenGestureType.swipe(direction: direction, velocity: evt.velocity ?? Vector2.default)
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

