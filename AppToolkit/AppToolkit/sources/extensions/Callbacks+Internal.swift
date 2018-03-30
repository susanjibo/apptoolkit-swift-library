//
//  Callbacks+Internal.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 11/20/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

protocol URIBasedInfo {
    var uri: String? { get set }
}

//MARK: - Video
class TakeVideoInfo: CallbackInfo, URIBasedInfo {
    var uri: String?
}

//MARK: - Photo
class TakePhotoInfoInternal: CallbackInfo, URIBasedInfo {
    var uri: String?
    var name: String?
    var positionTarget: Vector3?
    var angleTarget: AngleVector?
}

extension TakePhotoInfo {
    convenience init(internal: TakePhotoInfoInternal) {
        self.init()
        name = `internal`.name
        positionTarget = `internal`.positionTarget
        angleTarget = `internal`.angleTarget
    }
}
