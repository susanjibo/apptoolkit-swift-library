//
//  ConfigToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class BaseConfigCommandToken<T: BaseCommand, Result: Any>: CommandToken<T, Result> {

    /**
     * Overrides super implementation
     */
    override func emitValue(_ value: Result) {
        super.emitValue(value)
        
        self.isComplete = true
    }
    
    override func handleAcknowledgement(_ data: Acknowledgement) {
        if let responseCode = data.body?.responseCode {
            if responseCode != ResponseCode.accepted {
                super.handleAcknowledgement(data)
            }
        }
    }
}

class GetConfigToken: BaseConfigCommandToken<GetConfigCommand, Never> {
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
                    callback?(nil, ErrorResponse(err))
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
            case .onConfig:
                if let info = ConfigInfo() {
                    let config = GetConfigInfo()
                    config.info = info
                    if let evt = eventBody as? ConfigEvent {
                        info.battery = evt.battery
                        info.wifi = evt.wifi
                        info.position = evt.position
                        info.mixers = evt.mixers
                    }
                    callback?(config, nil)
                    emitValue(Never())
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }

            default:
                print("Wrong event!!! \(eventBody)")
                break
            }
        } else {
            callback?(nil, ErrorResponse(CommandError.badEvent))
        }
    }
}

class SetConfigToken: BaseConfigCommandToken<SetConfigCommand, Never> {
    /**
     * Overrides super implementation
     */
    override func handleEvent(_ data: EventMessage) {
        if isValidEvent(data), let eventBody = data.body {
            switch eventBody.event {
            case .asyncStop:
                let info = SetConfigInfo()
                info.succeed = true
                emitValue(Never())
                callback?(info, nil)

            case .asyncError:
                if let evt = eventBody as? AsyncErrorEvent, let err = evt.eventError {
                    callback?(nil, ErrorResponse(err))
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
                
            default:
                print("Wrong event!!! \(eventBody)")
                break
            }
        } else {
            callback?(nil, ErrorResponse(CommandError.badEvent))
        }
    }
}
