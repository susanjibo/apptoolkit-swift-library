//
//  ApiResponse.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/24/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

private let DataID = "data"
private let ErrorsID = "errors"

protocol ApiResponse: StaticMappable {
    func isApiCall() -> Bool
    func isAuthCall() -> Bool
}

extension ApiResponse {
    
    static func objectForMapping(map: Map) -> BaseMappable? {
        if let _: Any? = map[DataID].value() {
            return ApiCallResponse()
        } else if let _: Any? = map[ErrorsID].value() {
            return ApiErrorResponse()
        } else {
            return AuthCallResponse.objectForMapping(map: map)
        }
    }
}

class ApiResponseBase: ModelObject, ApiResponse {
    
    func isApiCall() -> Bool {
        return false
    }
    
    func isAuthCall() -> Bool {
        return false
    }
}

class ApiCallBodyBase: ModelObject {
}


class ApiCallResponse: ApiResponseBase {
    typealias JSON = [String: AnyObject]
    var dataArray: [ApiCallBodyBase]?
    var data: ApiCallBodyBase?

    override func mapping(map: Map) {
        data        <- (map[DataID], ApiCallResponseSerializationTransform())
        dataArray   <- (map[DataID], ApiCallResponseSerializationTransform())
    }

    override func isApiCall() -> Bool {
        return true
    }

}

class ApiCallResponseSerializationTransform: TransformType {
    typealias Object = ApiCallBodyBase
    typealias JSON = [String: Any]
    
    init() {}
    
    enum ApiCallType {
        case unknown
        case robotsList
        case certificateCreate
        case certificateRetrieve
    }
    
    func transformFromJSON(_ value: Any?) -> ApiCallBodyBase? {
        guard let json = value as? JSON else { return nil }
        
        let apiType = self.apiCallType(from: json)
        
        return self.apiCallBody(from: apiType, json: json)
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        assertionFailure("Not implemented")
        return nil
    }
    
    fileprivate func apiCallType(from json: JSON) -> ApiCallType {
        var apiType = ApiCallType.unknown
        
        // Check API call type — could be 'RobotList', 'Certificate Create' and 'Certificate Retrieve' call responses
        // According to documentation if JSON has 'id', 'name', 'robotName' it is safe to treat it as 'RobotList' API call response
        // Otherwise it would be one of 'certificateCreate', 'certificateRetrieve' calls
        // The only difference between the last is the presence of 'created' field in ther JSON response
        
        if let _ = json[RobotParams.id] as? String,
            let _ = json[RobotParams.name] as? String,
            let _ = json[RobotParams.robotName] as? String {
            apiType = .robotsList
        } else if let _ = json[CertificateParams.fingerprint] as? String,
            let _ = json[CertificateParams.private] as? String,
            let _ = json[CertificateParams.public] as? String,
            let _ = json[CertificateParams.cert] as? String {
            apiType = .certificateRetrieve
        } else if let _ = json[CertificateParams.created] as? Int {
            apiType = .certificateCreate
        }
        
        return apiType
    }
    
    fileprivate func apiCallBody(from apiType: ApiCallType, json: JSON) -> ApiCallBodyBase? {
        switch apiType {
        case .robotsList:
            return Mapper<RobotInfo>().map(JSON: json)
        case .certificateCreate:
            return Mapper<CertificateCreateInfo>().map(JSON: json)
        case .certificateRetrieve:
            return Mapper<CertificateInfo>().map(JSON: json)
        default:
            return nil
        }
    }
}
