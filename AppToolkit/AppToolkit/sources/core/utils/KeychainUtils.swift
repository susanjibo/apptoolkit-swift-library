//
//  KeychainUtils.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/20/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import KeychainAccess
import ObjectMapper

//MARK: - Simulator's certificate for accepting the apps CA
let jiboCert = """
-----BEGIN CERTIFICATE-----
MIIGKjCCBBKgAwIBAgIJALnJKuSFa0tlMA0GCSqGSIb3DQEBCwUAMIGhMQswCQYD
VQQGEwJFUzEMMAoGA1UECAwDTUFEMQwwCgYDVQQHDANNQUQxDzANBgNVBAoMBkVW
RVJJUzEhMB8GA1UECwwYSW5ub3ZhdGlvbi1KaWJvLURlbW8tMDAxMSswKQYDVQQD
DCJFdmVyaXMtSW5ub3ZhdGlvbi1KaWJvLURlbW8tMDAxLWNhMRUwEwYJKoZIhvcN
AQkBFgZub21haWwwHhcNMTcwNjI5MTAxMTE5WhcNMzcwNjI0MTAxMTE5WjCBoTEL
MAkGA1UEBhMCRVMxDDAKBgNVBAgMA01BRDEMMAoGA1UEBwwDTUFEMQ8wDQYDVQQK
DAZFVkVSSVMxITAfBgNVBAsMGElubm92YXRpb24tSmliby1EZW1vLTAwMTErMCkG
A1UEAwwiRXZlcmlzLUlubm92YXRpb24tSmliby1EZW1vLTAwMS1jYTEVMBMGCSqG
SIb3DQEJARYGbm9tYWlsMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
vKWHswRdwDi8ojJ/a1bBPkmB/N+nf68BuunfY1EVfsDM5eO7WsKoHjMFxNTsOUPn
mmZl85LY6Rp+Lfv3PTTO+fV3jPFg2032vDpdlFy/XkAHOLNFeYvyyJQasATK12el
hhihZyD8Y92alRVvDXrlcBAnOQeANX+xWFLA+at7HXvcS/H/ZckHgL+tz/Z54vmt
eBSOObn0QWqDXVdZWV1HNtb3nBwnjJnU5B50OafvFC8Sfoj2voLeesDCfsOQml3w
eOww5uZb7RcP7h3YqP7/EyyfbvBu7KPuMzi/k5G88wLASsKjX0fjawIt6KeI151V
i8/g7u11hn0Qbugn+DmIaeAphbFISDDc76XYX03kZs9tMSi80Ur9NQy79D1iO5iB
nvv4/WwAEwf3z/w525pltgJgnYAytkt8Iu/Jys306GdoShetQLff3ijd+ZndlmM3
G/g1O74Odoq9txVMb2zDoyxFdUWdkhQSGYHD+XqXHj74WyycAy+tJO6GsRjFDz1t
zxbDIfdbQUyBse5WMIERxDlEDA/XED9nV01RDlf+g/xX7VNzSliW4GKYDd01/FE3
6EDSXie85aUepANTM9zhhnJu2HxHGBbgHLgWYdJpGZXqSmnJZyk5vleOUzD3pPI2
+K/KZ8s2dKGbId92n0ENALXN6TBEvZlEkbSusr/GLnsCAwEAAaNjMGEwHQYDVR0O
BBYEFCBXRR6oWJm6jR8R7g5bwTxhr/dsMB8GA1UdIwQYMBaAFCBXRR6oWJm6jR8R
7g5bwTxhr/dsMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMA0GCSqG
SIb3DQEBCwUAA4ICAQCZggfYR1r9I4LuTpbvwqMwGqi5DvY8NkukZcB4tABhanEk
ACfIlW6NWs3GWlQrS4Mdcr8v0+mJ0Cgz7tvKvz6sw2gyW2BzXCjw9/lmCcWRrZVZ
c1RvOVlfB92fQ8LOvvOsVowN3UsCm4RgQcSmNi3tjqJWJtpCweivjoy376GmgvzO
qbhVLTNtALe20iQGyeTRafvMSyg/x2ADRWXwgGY5InHD6yMLfFKC2m03oJCKWNt2
IkjL9iHr/usFufataR4axO8F4VBGOb5/oLRwvVE0/Rez3hIYpLFEWswbvaZa13SR
Bc+YmnTILmD+NsL3Hl+qLZfFqXSwjY8XDpvU3o1S0+sVmGER+Vgai4oqe7DrzuCZ
SBG5OIoV2nlNUYMf3zG1avOE5xXjarZpQ5CBDF/oy0Nvxo06QHFK86oy3mTHCGuQ
0WiC/yC0frhZi5BmeFsiAgbH7NYgXJQPI7g2K8U5FvwDNZPbDIlph30WPZ/RaoVM
kj9UxQ0lNTVuOY6PsjnfpvCot2qXxvGHwmZiy6/m8s32mRj33WXrrKycYp3hNW8Y
OZZ8cT6McHlLsYJtIOAiiHl79LJnKsUAkU/N23CgVW5JstTqX+fqCaOz7z0T1hNH
o/3/TAwiVBMRGdi7uox9Lj9ErAPIkicdpDDBd98yJo58xFpidtQ+Arlj8J+sOg==
-----END CERTIFICATE-----
"""


struct KeychainConfiguration {
	static let serviceName = "com.jibo.rom"
	static let accessGroup: String? = nil
}

class KeychainUtils {
	
	static var keychain: Keychain = {
		let keychain = Keychain(service: KeychainConfiguration.serviceName)
		return keychain.accessibility(.whenUnlocked)
	}()
	
}

// MARK: - KeychainUtils + Token
extension KeychainUtils {
	
	static func saveTokenIfValid(token: Token) -> Bool {
		if token.isValid() {
			keychain[OAuthParams.accessToken] = token.accessToken
			keychain[OAuthParams.refreshToken] = token.refreshToken
			keychain[OAuthParams.tokenType] = token.type.rawValue
			keychain[OAuthParams.creationDate] = DateUtils.dateToString(date: token.creationDate)
		}
		return token.isValid()
	}

    static func removeToken() {
        keychain[OAuthParams.accessToken] = nil
        keychain[OAuthParams.refreshToken] = nil
        keychain[OAuthParams.tokenType] = nil
		keychain[OAuthParams.creationDate] = nil
    }

    @discardableResult
	static func obtainOrRemoveTokenIfNotValid() -> Token? {
		guard let token = Token(),
				let accessToken = keychain[OAuthParams.accessToken],
				let refreshToken = keychain[OAuthParams.refreshToken],
				let typeRawValue = keychain[OAuthParams.tokenType],
				let creationDateString = keychain[OAuthParams.creationDate],
				let creationDate = DateUtils.dateFromString(stringDate: creationDateString),
				let type = TokenType(rawValue: typeRawValue) else { return nil }
		token.accessToken = accessToken
		token.refreshToken = refreshToken
		token.type = type
		token.creationDate = creationDate
		
		if !token.isValid() {
			KeychainUtils.removeToken()
			return nil
		} else {
			return token
		}
	}
	
}

// MARK: - KeychainUtils + Certificate

extension Data {
    fileprivate func asStorage() -> KeychainUtils.CertificatesStorage? {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as? KeychainUtils.CertificatesStorage
    }
}

extension Dictionary {
    fileprivate func asData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

extension KeychainUtils {
    typealias Certificate = [String: Any]
    typealias CertificatesStorage = [String: Certificate]
    static let certificatesStorageKey = "certificatesStorageKey"
    
    static func saveCertificate(_ certificate: CertificateInfo, for robot: String) {
        var storage: CertificatesStorage? = keychain[data: certificatesStorageKey]?.asStorage()
        if storage == nil {
            storage = CertificatesStorage()
        }
        storage?[robot] = certificate.toJSON()
        keychain[data: certificatesStorageKey] = storage?.asData()
    }

    static func removeCertificate(for robot: String) {
        if var storage = keychain[data: certificatesStorageKey]?.asStorage() {
            storage[robot] = nil
            keychain[data: certificatesStorageKey] = storage.asData()
        }
    }

    static func getCertificate(for robot: String) -> CertificateInfo? {
        if let storage: CertificatesStorage = keychain[data: certificatesStorageKey]?.asStorage(),
            let certData = storage[robot] {
            return Mapper<CertificateInfo>().map(JSON: certData)
        }
        return nil
    }

    static func removeCertificates() {
        keychain[data: certificatesStorageKey] = nil
    }

}
