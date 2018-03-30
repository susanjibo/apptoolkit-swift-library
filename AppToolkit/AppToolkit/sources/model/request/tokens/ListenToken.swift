//
//  ListenToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class ListenToken: CommandToken<ListenCommand, Never> {
    
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
                    let info = ListenInfo()
                    info.error = err
                    callback?(info, nil)
                    emitError(err)
                } else {
                    emitError(ErrorResponse(CommandError.badEvent))
                }
            case .listenStop:
                let info = ListenInfo()
                info.listen = ListenEntity()
                if let evt = eventBody as? ListenStopEvent {
                    info.listen?.reason = evt.stopReason?.rawValue ?? "Listening for speech stopped"
                    info.listenType = ListenInfo.ListenType.stop(reason: evt.stopReason?.rawValue ?? "Listening for speech stopped")
                }
                callback?(info, nil)
            case .listenResult:
                let info = ListenInfo()
                info.listen = ListenEntity()
                if let evt = eventBody as? ListenResultEvent {
                    info.listen?.speech = evt.speech
                    info.listen?.languageCode = evt.languageCode
                    info.listenType = ListenInfo.ListenType.speech(speech: SpeechInfo(speech: evt.speech, languageCode: evt.languageCode))
                }
                callback?(info, nil)
            case .onHotWordHeard:
                let info = ListenInfo()
                info.listen = ListenEntity()
                if let evt = eventBody as? HotWordHeardEvent, let speaker = evt.speaker, let lps = speaker.lpsPosition, let speakerId = speaker.speakerID {
                    let speakerID = SpeakerId(type: speakerId.type, confidence: speakerId.confidence)
                    let lpsPosition = LPSPosition(position: lps.position, angleVector: lps.angleVector, confidence: lps.confidence)
                    info.listen?.speaker = Speaker(lpsPosition: lpsPosition, speakerID: speakerID)
                    info.listenType = ListenInfo.ListenType.hotWord(hotWord: HotWordInfo(speaker: Speaker(lpsPosition: lpsPosition, speakerID: speakerID)))
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
