//
//  FetchAssetCommand.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/7/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class FetchAssetCommand: Command {
    var uri: String? = nil
    var name: String? = nil

    required init?(map: Map) {
        super.init(map: map)
        
        self.type = .fetchAsset
    }
    
    convenience init?(uri: String, name: String) {
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
        
        self.uri = uri
        self.name = name
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        uri  <- map["URI"]
        name <- map["Name"]
    }
    
}
