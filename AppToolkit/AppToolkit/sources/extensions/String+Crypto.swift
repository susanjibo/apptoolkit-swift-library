//
//  String+Crypto.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/17/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import CommonCryptoModule
import Starscream
import Security

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

// MARK: - Transaction ID
extension String {
    
    // Generates Command Transaction ID
    func transactionId() -> TransactionID {
        let hashSource = self + String(Date().timeIntervalSince1970)
        return hmac(algorithm: .MD5, key: hashSource)
    }
    
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    private func stringFromResult(_ result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
    }
}

//МАРК: - PEM
extension String {
    //PEM specific constants
    private static let pemCertificateHeader = "-----BEGIN CERTIFICATE-----"
    private static let pemCertificateTrailing = "-----END CERTIFICATE-----"
    private static let pemPrivateKeyHeader = "-----BEGIN RSA PRIVATE KEY-----"
    private static let pemPrivateKeyTrailing = "-----END RSA PRIVATE KEY-----"
    
    func isPEMCertificate() -> Bool {
        let pemBasedString = pemString
        return pemBasedString.hasPrefix(String.pemCertificateHeader) && pemBasedString.hasSuffix(String.pemCertificateTrailing)
    }
    
    func isPEMPrivateKey() -> Bool {
        let pemBasedString = pemString
        return pemBasedString.hasPrefix(String.pemPrivateKeyHeader) && pemBasedString.hasSuffix(String.pemPrivateKeyTrailing)
    }
    
    func asPEMCertificateString() -> String? {
        let pemBasedString = pemString
        guard pemBasedString.isPEMCertificate() else { return nil }
        
        #if swift(>=3.2)
            let index = pemBasedString.index(pemBasedString.startIndex, offsetBy: String.pemCertificateHeader.count+1)
        #else
            let index = pemBasedString.index(pemBasedString.startIndex, offsetBy: String.pemHeader.characters.count+1)
        #endif
        var certStr = pemBasedString.substring(from: index)
        
        if let lowerBound = certStr.range(of: String.pemCertificateTrailing)?.lowerBound {
            certStr = certStr.substring(to: lowerBound)
        }
        return certStr
    }
    
    func asPEMPrivateKeyString() -> String? {
        let pemBasedString = pemString
        guard pemBasedString.isPEMPrivateKey() else { return nil }
        
        #if swift(>=3.2)
            let index = pemBasedString.index(pemBasedString.startIndex, offsetBy: String.pemPrivateKeyHeader.count+1)
        #else
            let index = pemBasedString.index(pemBasedString.startIndex, offsetBy: String.pemPrivateKeyHeader.characters.count+1)
        #endif
        var certStr = pemBasedString.substring(from: index)
        
        if let lowerBound = certStr.range(of: String.pemPrivateKeyTrailing)?.lowerBound {
            certStr = certStr.substring(to: lowerBound)
        }
        return certStr
    }
    
    // Repair PEM string format if needed
    private var pemString: String {
        let result = components(separatedBy: NSCharacterSet.newlines).filter{!$0.isEmpty}.joined(separator: "\n")
        return result
    }

}
