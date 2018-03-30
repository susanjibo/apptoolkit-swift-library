//
//  SetConfigCommand.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/6/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class SetConfigCommand: Command {
    var configOptions: SetConfigOptionsProtocol?
    
    required init?(map: Map) {
        super.init(map: map)
        
        self.type = .setConfig
    }
    
    convenience init?(_ options: SetConfigOptionsProtocol) {
        let map = Map(mappingType: .fromJSON, JSON: [:])
        self.init(map: map)
        
        if let configOptions = SetConfigOptions(map: map) {
            configOptions.mixer = options.mixer
            self.configOptions = configOptions
        } else {
            return nil
        }
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        configOptions <- (map["Options"], BasicProtocolTypeSerializationTransform<SetConfigOptions, SetConfigOptionsProtocol>())
    }
}

