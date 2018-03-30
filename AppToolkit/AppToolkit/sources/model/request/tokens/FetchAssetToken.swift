//
//  FetchAssetToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/7/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class FetchAssetToken: CommandToken<FetchAssetCommand, Never> {
    
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
                    let info = FetchAssetInfo()
                    info.error = err
                    callback?(info, nil)
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
            case .assetReady:
                let info = FetchAssetInfo()
                if let evt = eventBody as? FetchAssetEvent, let detail = evt.detail {
                    info.detail = detail
                }
                callback?(info, nil)

            case .assetFailed:
                var err: Error = CommandError.badEvent
                if let evt = eventBody as? FetchAssetErrorEvent{
                    err = evt.asError()
                }
                callback?(nil, ErrorResponse(err))
                emitError(err)

            default:
                print("Wrong event!!! \(eventBody)")
                break
            }
        } else {
            callback?(nil, ErrorResponse(CommandError.badEvent))
        }
    }
}
