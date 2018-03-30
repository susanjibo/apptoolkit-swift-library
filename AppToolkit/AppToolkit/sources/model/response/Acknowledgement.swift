//
//  Acknowledgement.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/2/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Response Code Enum
 */
enum ResponseCode: Int {
    /** The Command was accepted and executed - synchronous calls only */
    case ok = 200
    /** If an Entity creation command (LoadAsset) was sent and it exists this is returned */
    case created = 201
    /** The command was accepted and will begin execution - most asynchronous commands will get a this response. */
    case accepted = 202
    /** Badly formatted request */
    case badRequest = 400
    /** Request is legal but not authorized for this application */
    case forbidden = 403
    /** The Command request is not a supported command */
    case notFound = 404
    /** The data in the Command is not acceptable */
    case notAcceptable = 406
    /** Unable to marshal the resources and set-up the command within the time limits set in the ROM Controller */
    case requestTimeout = 407
    /** There is a conflicting Command already executing */
    case conflict = 409
    /** The execution of the Command requires the execution of a prior Command */
    case preconditionFailed = 412
    /** The ROM Controller has crashed or hit a different error that was unexpected */
    case internalError = 500
    /** The ROM Controller is temporarily unavailable. The Robot SSM may be rebooting something. */
    case serviceUnavailable = 503
    /** The Version requested is not supported */
    case versionNotSupported = 505

    static func >=(left: ResponseCode, right: ResponseCode) -> Bool {
        return left.rawValue >= right.rawValue
    }
    
    func asString() -> String {
        let bundle = Bundle(for: CommandLibrary.self)
        return NSLocalizedString("response."+String(describing:self), bundle: bundle, comment: "")
    }

    func asDescription() -> String {
        let bundle = Bundle(for: CommandLibrary.self)
        return NSLocalizedString("response.description."+String(describing:self), bundle: bundle, comment: "")
    }
}

fileprivate let ResponseID = "Response"
fileprivate let ResponseBodyID = "ResponseBody"
fileprivate let ResponseBodySessionID = "SessionID"

class Acknowledgement: ResponseBase {
    var header: ResponseHeader?
    var body: AcknowledgementBody?

    override func mapping(map: Map) {
        header  <- map[ResponseHeaderID]
        body    <- (map[ResponseID], AcknowledgementSerializationTransform())
    }
    
    override func isAcknowledgement() -> Bool {
        return true
    }
}

class AcknowledgementBody: ModelObject {
    var value: String?
    var responseCode: ResponseCode?
    var responseString: String?
    var errorDetail: String?

    override func mapping(map: Map) {
        value           <- map["Value"]
        responseCode    <- map["ResponseCode"]
        responseString  <- map["ResponseString"]
        errorDetail     <- map["ErrorDetail"]
    }
}

class AcknowledgementSerializationTransform: TransformType {
    typealias Object = AcknowledgementBody
    typealias JSON = [String: AnyObject]
    
    init() {}
    
    enum AcknowledgementType {
        case generic
        case startSession
		case cancel
    }
    
    func transformFromJSON(_ value: Any?) -> AcknowledgementBody? {
        guard let json = value as? JSON else { return nil }
        
        let ackType = self.acknowledgementType(from: json)
        
		return self.acknowledgementBody(from: ackType, json: json)
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        assertionFailure("Not implemented")
        return nil
    }
	
	fileprivate func acknowledgementType(from json: JSON) -> AcknowledgementType {
		var ackType = AcknowledgementType.generic
		if let jsonBody = json[ResponseBodyID] as? JSON {
			if jsonBody[ResponseBodySessionID] as? String != nil {
				ackType = .startSession
			}
		} else if let _ = json[ResponseBodyID] as? String {
			ackType = .cancel
		}
		
		return ackType
	}
	
	fileprivate func acknowledgementBody(from ackType: AcknowledgementType, json: JSON) -> AcknowledgementBody? {
		switch ackType {
		case .generic:
			return Mapper<AcknowledgementBody>().map(JSON: json)
		case .startSession:
			return Mapper<StartSessionResponse>().map(JSON: json)
		case .cancel:
			return Mapper<CancelResponse>().map(JSON: json)
		}
	}
}
