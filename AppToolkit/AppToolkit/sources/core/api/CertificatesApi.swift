//
//  CertificatesApi.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/18/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Alamofire
import ObjectMapper

enum CertificatesParamFactory: RequestParamsFactory {
	case create(robotId: String)
	case retrieve(robotId: String)
	
	var path: String? {
		switch self {
		case .create:
			return EnvironmentSwitcher.shared().currentConfiguration.certificatesCreationUrl
		case .retrieve:
			return EnvironmentSwitcher.shared().currentConfiguration.certificatesRetrievalUrl
		}
	}
	
	var method: HTTPMethod {
		switch self {
		case .create:
			return .post
		case .retrieve:
			return .get
		}
	}
	
    var requestParams: RequestParamsConvertable {
		switch self {
		case .create(let robotId):
            return CreateCertificateParams(robotId: robotId)
		case  .retrieve(let robotId):
			return RetrieveCertificateParams(robotId: robotId)
		}
	}
}

//MARK: - Create certificate params
class CreateCertificatBody: ModelObject {
    var robotId: String?

    override public func mapping(map: Map) {
        robotId <- map[CertificateParams.friendlyId]
    }

}

struct CreateCertificateParams: RequestParamsConvertable {
    let robotId: String
    
    func asRequestParams() -> RequestParams {
        if let certificateBody = CreateCertificatBody() {
            certificateBody.robotId = robotId
            return certificateBody.toJSON()
        }
        return [:]
    }
}

//MARK: - Retrieve certificate params
struct RetrieveCertificateParams: RequestParamsConvertable {
    let robotId: String
    
    func asRequestParams() -> RequestParams {
        var params = [String: Any]()
        
        params[CertificateParams.friendlyId] = robotId
        
        return params
    }
}
