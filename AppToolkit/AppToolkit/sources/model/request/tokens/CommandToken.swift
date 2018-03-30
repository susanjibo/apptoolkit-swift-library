//
//  CommandToken.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import PromiseKit

/**
 Unique ID issued for every command. You'll only need to use this command to 
 cancel an in-progress transaction.
*/
public typealias TransactionID = String
typealias TockenFinalizer = (() -> ())

protocol CommandTokenProtocol {
    var transactionId: TransactionID? {get set}
    var isComplete: Bool {get set}

    func handleAcknowledgement(_ data: Acknowledgement)
    func handleEvent(_ data: EventMessage)
    
    func finalize()
    func forceComplete(with error: Error)
}

class CommandToken<T: BaseCommand, Result: Any>: CommandTokenProtocol {

    var command: T? = nil
    var transactionId: TransactionID? = nil
    var isComplete: Bool
    internal var callback: CommandLibraryInterface.CallbackClosure? // closure to be called on success
    internal var finalizer: TockenFinalizer? // token cleanup closure
    fileprivate var completePromise: ExternalPromise<Result>
    
    init(_ command: T, transactionId: TransactionID? = nil) {
        self.command = command
        self.transactionId = transactionId
        isComplete = false
        completePromise = ExternalPromise<Result>()
    }
    
    func handleAcknowledgement(_ data: Acknowledgement) {
        if let responseCode = data.body?.responseCode {
            if responseCode >= .badRequest {
                emitError(NSError(domain: "com.jibo.rom", code: responseCode.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: responseCode.asString(), NSLocalizedDescriptionKey: responseCode.asDescription()]) as Error)
            } else if responseCode == ResponseCode.ok {
                emitValue(data.body as! Result)
            } else if responseCode == ResponseCode.accepted {
                emitValue(Never() as! Result)
            }
        }
    }

    func handleEvent(_ data: EventMessage) {
        // Base class might handle only one event, after that commands treated as completed
        if isValidEvent(data), let eventBody = data.body, let eventType = data.body?.event {
            callback?(nil, ErrorResponse(EventMessageError.unsupported(event: eventType.rawValue, bodyType: String(describing: eventBody))))
            isComplete = true
        }
    }

    func finalize() {
        finalizer?()
    }
    
    func forceComplete(with error: Error) {
        emitError(error)
    }
    
    func complete() -> Promise<Result> {
        return completePromise.promise
    }
    
    func emitValue(_ value: Result) {
        completePromise.fulfill(value)
    }
    
    func emitError(_ error: Error) {
        completePromise.reject(error)
        isComplete = true
    }

    // MARK: Private
    
    internal func isValidEvent(_ event: EventMessage) -> Bool {
        // If event is invalid (bad JSON...) it treated as completed to be removed from list of pending commands
        guard let _ = event.body, let _ = event.body?.event else {
            let bodyType = event.body == nil ? nil : String(describing: event.body)
            let error = EventMessageError.invalid(event: event.body?.event.rawValue, bodyType: bodyType)
            callback?(nil, ErrorResponse(error))
            isComplete = true
            return false
        }
        return true
    }
}

fileprivate final class ExternalPromise<T> {
    fileprivate var fulfill: (T) -> ()
    fileprivate var reject: (Error) -> ()
    fileprivate var promise: Promise<T>
    
    init() {
        let (p, f, r) = Promise<T>.pending()
        promise = p
        fulfill = f
        reject = r
    }
}
