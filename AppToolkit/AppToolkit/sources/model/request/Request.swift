//
//  Request.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 9/29/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/**
:nodoc
*/
class Request<T: BaseCommand>: ModelObject {
    
    public var header: RequestHeader?
    public var command: T?
    
    override public func mapping(map: Map) {
        header  <- map["ClientHeader"]
        command <- map["Command"]
    }
}
