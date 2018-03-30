//
//  FetchAssetEvent.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/7/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class FetchAssetEvent: BaseEvent {
    var detail: String? = nil
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        detail <- map["Detail"]
    }
}

class FetchAssetErrorEvent: BaseEvent {
    var errorDetail: String? = nil
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        errorDetail <- map["ErrorDetail"]
    }
    
    func asError() -> Error {
        struct FetchAssetError: Error {
            let detail: String
            
            var localizedDescription: String {
                return detail
            }
        }
        return FetchAssetError(detail: errorDetail ?? "Asset fetch failed")
    }
}
