//
//  URL+Extensions.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/18/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

enum Flavor {
    case undefined
    case redirectForLogin(code: String, state: String)
    case accessDenied(error: Error)
}

fileprivate let CodeItemID = "code"
fileprivate let StateItemID = "state"
fileprivate let ErrorItemID = "error"

extension URL {
    
    func flavor() -> Flavor {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems {
            if queryItems.filter({$0.name == CodeItemID || $0.name == StateItemID}).count == 2 {
                return .redirectForLogin(code: codeItem()!, state: stateItem()!)
            } else if errorItem() != nil {
                return .accessDenied(error: ApiError.accessDenied)
            }
        }
        return .undefined
    }
    
    private func codeItem() -> String? {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems {
            return queryItems.filter({$0.name == CodeItemID}).first?.value
        }
        return nil
    }

    private func stateItem() -> String? {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems {
            return queryItems.filter({$0.name == StateItemID}).first?.value
        }
        return nil
    }

    private func errorItem() -> String? {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems {
            return queryItems.filter({$0.name == ErrorItemID}).first?.value
        }
        return nil
    }
}
