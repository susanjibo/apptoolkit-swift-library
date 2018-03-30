//
//  RequestCommand.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 9/29/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

enum CommandType: String {
    case undefined
    case startSession   = "StartSession"
    case getConfig      = "GetConfig"
    case setConfig      = "SetConfig"
    case cancel         = "Cancel"
    case setAttention   = "SetAttention"
    case say            = "Say"
    case listen         = "Listen"
    case lookAt         = "LookAt"
    case takePhoto      = "TakePhoto"
    case video          = "Video"
    case subscribe      = "Subscribe"
    case display        = "Display"
    case fetchAsset     = "FetchAsset"
}

protocol BaseCommand: Mappable {
    init?()
    var type: CommandType { get set }
}

class Command: ModelObject, BaseCommand {
    var type: CommandType = .undefined

    override func mapping(map: Map) {
        type    <- map["Type"]
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
}
