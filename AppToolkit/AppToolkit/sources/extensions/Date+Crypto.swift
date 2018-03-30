//
//  Date+Crypto.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/17/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

extension Date {
    func generateToken() -> String {
        let hashSource = String(timeIntervalSince1970) + "Date-\(arc4random())-\(arc4random())"

        return String(timeIntervalSince1970).hmac(algorithm: .MD5, key: hashSource)
    }
}
