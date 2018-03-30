//
//  MockCommandRequester.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/9/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import PromiseKit
@testable import AppToolkit

let mockTransactionID: String = "79054025255fb1a26e4bc422aef54eb4"
let mockSessionID: String = "TestSessionId"

class MockCommandRequester: CommandRequester {

    func getSessionId() -> String? {
        return mockSessionID
    }

    enum ConnectionStatus {
        case connected, unconnected, error
    }
    var connectionStatus: ConnectionStatus = .unconnected
    func connect() -> Promise<Bool> {
        switch connectionStatus {
        case .connected: return Promise(value: true)
        case .unconnected: return Promise(value: false)
        case .error: return Promise(error: MockError())
        }
    }

    var disconnected = false
    func disconnect() -> Promise<Bool> {
        return Promise(value: disconnected)
    }

    func getConfig(_ callback: CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }

    func setConfig(_ options: SetConfigOptionsProtocol, callback: CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }
    
    func cancel(transactionId: String) -> Promise<CancelResponse> {
        return Promise(error: MockError())
    }

    func takeVideo(videoType: VideoType, duration: TimeInterval, callback: CommandRequester.CommandCallback?, finalizer: TockenFinalizer?) -> CommandTransaction<AppToolkit.Never> {
		return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
	}
	
	func takePhoto(with camera: Camera, resolution: CameraResolution, distortion: Bool, callback: CommandRequester.CommandCallback?, finalizer: TockenFinalizer?) -> CommandTransaction<AppToolkit.Never> {
		return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
	}
	
	func lookAt(targetType: LookAtTargetType, trackFlag: Bool, levelHeadFlag: Bool, callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
		return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
	}
	
	func say(phrase: String, callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
		return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
	}

    func entityRequest(callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }
    
    func displayEye(in view: String, callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }
    
    func displayText(_ text: String, in view: String, callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }
    
    func displayImage(_ image: ImageData, in view: String, callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }
    
    func getMotion(callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }

    func listenForSpeech(maxSpeechTimeOut: Timeout, maxNoSpeechTimeout: Timeout, languageCode: LangCode, callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }
    
    func listenForHeadTouch(callback: CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }
    
    func fetchAssetWithURI(_ uri: String, name: String, callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }
    
    func listenForScreenGesture(_ params: ScreenGestureListenParams, callback: CommandRequester.CommandCallback?) -> CommandTransaction<AppToolkit.Never> {
        return CommandTransaction(transactionId: mockTransactionID, tokenAcknowledged: Promise(value: Never()))
    }

}

struct MockError: Error {}

class MockConfigInfo: ModelObject, ConfigInfoProtocol {
    var battery: BatteryProtocol?
    var wifi: WiFiProtocol?
    var position: PositionProtocol?
    var mixers: MixersProtocol?
}
