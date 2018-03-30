//
//  Error.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/18/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

/**
 :nodoc:
 */
public protocol ErrorStatusCode {
    func statusCode() -> Int
}

//MARK: - Errors
/**  
 Errors received from ROM API calls 
 */
public enum ApiError: Error, ErrorStatusCode {
    /// 1001
	case notAuthorized
    /// 1002
	case tokenRefreshFailed
    /// 1003
	case emptyAuthCode
    /// 1004
	case emptyURL
    /// 1005
    case accessDenied
    /// 1006
    case certificateCreateError
    /// 1007
    case certificateFetchError
    /// 1008
    case badRequest
    /// 1009
    case noInternet

    /** :nodoc: */
    public func statusCode() -> Int {
        switch self {
        case .notAuthorized:
            return -1001
        case .tokenRefreshFailed:
            return -1002
        case .emptyAuthCode:
            return -1003
        case .emptyURL:
            return -1004
        case .accessDenied:
            return -1005
        case .certificateCreateError:
            return -1006
        case .certificateFetchError:
            return -1007
        case .badRequest:
            return -1008
        case .noInternet:
            return -1009
        }
    }
    
}

/// Errors received from ROM commands
public enum CommandError: Error, ErrorStatusCode {
    /// 1011
    case commandFailedInit
    /// 1012
    case configNotFound
    /// 1013
    case badEvent

    /// :nodoc:
    public func statusCode() -> Int {
        switch self {
        case .commandFailedInit:
            return -1011
        case .configNotFound:
            return -1012
        case .badEvent:
            return -1013
        }
    }
}

/// Errors received from event listening
public enum EventMessageError: Error, ErrorStatusCode {
    
    /// 1021: The event message received has an invalid event and/or body
    case invalid(event: String?, bodyType: String?)
    
    /// 1022:  SDK recieved an unsupported event. Event is deprecated or unimplemented.
    case unsupported(event: String, bodyType: String)

    /// :nodoc:
    public func statusCode() -> Int {
        switch self {
        case .invalid:
            return -1021
        case .unsupported:
            return -1022
        }
    }
}

// MARK: - Error Response
/// Error Reponse info
public class ErrorResponse: Error {
    /// error response code
    public let statusCode: Int
    /// error data
    public let body: Data?
    /// error
    public let error: Error
    /// :nodoc:
    public init(statusCode: Int, body: Data?, error: Error) {
        self.statusCode = statusCode
        self.body = body
        self.error = error
    }
    /// :nodoc:
    public func asNSError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: error.localizedDescription]
//TODO: parse response
//        if let json = body?.jsonObject(type: [String: Any].self) {
//        }
        
        return NSError(code: statusCode, userInfo: userInfo)
    }
    
}

/// :nodoc:
extension ErrorResponse {
    convenience init(_ apiError: ApiError) {
        self.init(statusCode: apiError.statusCode(), body: nil, error: apiError)
    }
    
    convenience init(_ romCommandError: CommandError) {
        self.init(statusCode: romCommandError.statusCode(), body: nil, error: romCommandError)
    }

    convenience init(_ error: Error) {
        if let error = error as? ApiError {
            self.init(error)
        } else {
            self.init(statusCode: -1, body: nil, error: error)
        }
    }
}
