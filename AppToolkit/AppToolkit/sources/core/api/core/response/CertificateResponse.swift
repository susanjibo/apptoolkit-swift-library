//
//  CertificateResponse.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/25/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

enum CertificateParams: String {
    case cert
    case `public`
    case `private`
    case fingerprint
    case p12
    case created
    case payload
    case friendlyId
}

protocol CertificateInfoBaseProtocol {
    var created: Int? { get set }
}

protocol CertificateInfoProtocol: CertificateInfoBaseProtocol {
    var cert: String? { get set }
    var `public`: String? { get set }
    var `private`: String? { get set }
    var fingerprint: String? { get set }
}

class RobotPayload: ModelObject {
    var ipAddress: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        ipAddress <- map["ipAddress"]
    }
}

class CertificateCreateInfo: ApiCallBodyBase, CertificateInfoBaseProtocol {
    var created: Int?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        created <- map[CertificateParams.created]
    }
}

class CertificateInfo: ApiCallBodyBase, CertificateInfoProtocol, Equatable {
    var cert: String?
    var `public`: String?
    var `private`: String?
    var fingerprint: String?
    var p12: String?
    var created: Int?
    var payload: RobotPayload?

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        cert        <- map[CertificateParams.cert]
        `public`    <- map[CertificateParams.public]
        `private`   <- map[CertificateParams.private]
        fingerprint <- map[CertificateParams.fingerprint]
        p12         <- map[CertificateParams.p12]
        created     <- map[CertificateParams.created]
        payload     <- map[CertificateParams.payload]
    }

    static func ==(lhs: CertificateInfo, rhs: CertificateInfo) -> Bool {
        return lhs.cert == rhs.cert
    }
    
    func getIpAddress() -> String?{
        return payload?.ipAddress
    }
}

extension CertificateInfo {
    func isValidCertificate() -> Bool {
        guard let _ = cert,
            let _ = `public`,
            let _ = `private`,
            let _ = fingerprint,
            let _ = created else { return false }
        
        return SocketSecurity(self).secCertificate() != nil
    }
}
