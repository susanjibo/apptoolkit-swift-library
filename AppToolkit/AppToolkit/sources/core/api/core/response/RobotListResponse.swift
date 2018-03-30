//
//  RobotListResponse.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/25/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ObjectMapper

enum RobotParams: String {
    case id
    case name
    case robotName
}
//MARK: Robot Info
/**
 Information about the authenticated robot.
 */
public protocol RobotInfoProtocol {
    /// Unique ID of the robot.
    var id: String? { get set }
    /// Loop name. Usually `<OwnerFirstName>'s Jibo`
    var name: String? { get set }
    /// My-Friendly-Robot-Name, found on the underside of the robot's base.
    var robotName: String? { get set }
}

class RobotInfo: ApiCallBodyBase, RobotInfoProtocol {
    var id: String?
    var name: String?
    var robotName: String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        id        <- map[RobotParams.id]
        name      <- map[RobotParams.name]
        robotName <- map[RobotParams.robotName]
    }
}

