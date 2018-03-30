//
//  VideoToken.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/5/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

class VideoToken: CommandToken<VideoCommand, Never> {
	
	override init(_ command: VideoCommand, transactionId: TransactionID?) {
		super.init(command, transactionId: transactionId)
	}
	
	override func emitValue(_ value: Never) {
        super.emitValue(value)
	}

    override func handleEvent(_ data: EventMessage) {
        if isValidEvent(data), let eventBody = data.body, let video = eventBody as? VideoReadyEvent {
            let info = TakeVideoInfo()
            info.uri = video.uri
            self.callback?(info, nil)
        } else {
            self.callback?(nil, ErrorResponse(CommandError.badEvent))
        }
    }
}
