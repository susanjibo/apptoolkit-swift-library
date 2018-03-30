//
//  SocketSecurity.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 11/14/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import Starscream
import CommonCryptoModule

class SocketSecurity: SSLTrustValidator {
    private var security: SSLSecurity
    private var certificateInfo: CertificateInfo
    
    init(_ certificateInfo: CertificateInfo) {
        var certificates: [SSLCert] = []
        if let certificate = SocketSecurity.secTrustInfo(certificateInfo),
            let key = SecTrustCopyPublicKey(certificate.trust) {
            let sslData = SSLCert(data: SecCertificateCopyData(certificate.cert) as Data)
            let sslKey = SSLCert(key: key)
            
            certificates = [sslData, sslKey]
        }
        self.certificateInfo = certificateInfo

        security = SSLSecurity(certs: certificates, usePublicKeys: true)
    }

    func secCertificate() -> SecCertificate? {
        return SocketSecurity.secTrustInfo(certificateInfo)?.cert
    }
    
    func isValid(_ trust: SecTrust, domain: String?) -> Bool {
        // Security check — veryfy that server and client fingerprints are equal, otherwise WebSocket SSL connection will be dropped
        let valid = trust.getSHA1Fingerprint() == certificateInfo.fingerprint
        if !valid {
            print("Certificate fingerprints aren't equal!!!")
        }
        return valid
    }
    
}

//MARK: - Trust Info
extension SocketSecurity {
    fileprivate static func secTrustInfo(_ info: CertificateInfo) -> (cert: SecCertificate, trust: SecTrust)? {
        guard let certStr = info.cert?.asPEMCertificateString() else { return nil }

        if let data = Data(base64Encoded: certStr, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters),
            let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData) {
            var trust: SecTrust?
            let policy = SecPolicyCreateBasicX509()
            let status = SecTrustCreateWithCertificates(certificate, policy, &trust)
            if status == errSecSuccess, let trust = trust {
                var trustResult = SecTrustResultType.invalid
                if (SecTrustEvaluate(trust, &trustResult) != errSecSuccess) {
                    return nil;
                } else {
                    switch trustResult {
                        // only errors treated as 'not trusted'
                    case .proceed, .unspecified, .recoverableTrustFailure:
                        return (certificate, trust)
                    default:
                        print("Trust failed")
                    }
                }
            }
            
            return nil
        }
        return nil
    }
}

//MARK: - Fingerprint
extension SecTrust {
    
    enum FingerprintType {
        case SHA1
        case SHA256
        case MD5
    }
    
    func getSHA1Fingerprint() -> String? {
        return getFingerprintWithType(.SHA1)
    }
    
    func getSHA256Fingerprint() -> String? {
        return getFingerprintWithType(.SHA256)
    }
    
    func getMD5Fingerprint() -> String? {
        return getFingerprintWithType(.MD5)
    }
    
    private func getFingerprintWithType(_ type: FingerprintType) -> String? {
        guard errSecSuccess == SecTrustEvaluate(self, nil),
            let certificate = SecTrustGetCertificateAtIndex(self, 0) else { return nil }
        
        let data = SecCertificateCopyData(certificate) as NSData
        
        let length = lengthWityType(type)
        var buffer = [UInt8](repeating:0, count:Int(length))
        
        switch(type) {
        case .SHA1:
            CC_SHA1(data.bytes, CC_LONG(data.length), &buffer)
        case .SHA256:
            CC_SHA256(data.bytes, CC_LONG(data.length), &buffer)
        case .MD5:
            CC_MD5(data.bytes, CC_LONG(data.length), &buffer)
        }
        
        let fingerPrint = NSMutableString()
        for byte in buffer {
            fingerPrint.appendFormat("%02x ", byte)
        }
        
        return fingerPrint.trimmingCharacters(in: NSCharacterSet.whitespaces).replacingOccurrences(of: " ", with: ":")
    }
    
    private func lengthWityType(_ type: FingerprintType) -> Int32 {
        switch type {
        case .SHA1:
            return CC_SHA1_DIGEST_LENGTH
        case .SHA256:
            return CC_SHA256_DIGEST_LENGTH
        case .MD5:
            return CC_MD5_DIGEST_LENGTH
        }
    }
}

extension CertificateInfo {
    func clientCerts() -> [Any]? {
        guard let (identity, cert) = getIdentityAndCert() else { return nil }

        return [identity, cert]
    }
    
    func clientIdentity() -> SecIdentity? {
        guard let (identity, _) = getIdentityAndCert() else { return nil }
        
        return identity
    }

    func clientCertificate() -> SecCertificate? {
        guard let (_, cert) = getIdentityAndCert() else { return nil }
        
        return cert
    }

    private func getIdentityAndCert() -> (identity: SecIdentity, certificate: SecCertificate)? {
        guard let p12 = p12, let data = Data(base64Encoded: p12, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else { return nil }
        
        var imported: CFArray? = nil
        
        let status = SecPKCS12Import(data as CFData, [kSecImportExportPassphrase: ""] as CFDictionary, &imported)
        switch status {
        case noErr:
            let identityDict = unsafeBitCast(CFArrayGetValueAtIndex(imported!, 0), to: CFDictionary.self) as NSDictionary
            let importItemIdentity = kSecImportItemIdentity as String
            let identity = identityDict[importItemIdentity] as! SecIdentity
            var cert: SecCertificate? = nil;
            if noErr == SecIdentityCopyCertificate(identity, &cert) {
                return (identity, cert!)
            }
            return nil
        case errSecAuthFailed:
            print("SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            return nil
        default:
            print("Failed to import the certificate data!")
            return nil
        }
    }
    
}

