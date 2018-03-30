//
//  MockEventListenerDelegate.swift
//  AppToolkitTests
//
//  Created by Justin Shiiba on 10/9/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
@testable import AppToolkit

class MockEventListenerDelegate {//: EventListenerDelegate {

    var didReceiveVideoCalled = false
    func didReceiveVideoURI(_ uri: String) {
        didReceiveVideoCalled = true
    }

    var didReceivePhotoCalled = false
    func didReceivePhotoURI(_ uri: String, forName name: String, at positionTarget: Vector3, angleTarget: AngleVector) {
        didReceivePhotoCalled = true
    }

    var didReceiveLookAtAchievedCalled = false
    func didReceiveLookAtAchieved(at positionTarget: Vector3, angleTarget: AngleVector) {
        didReceiveLookAtAchievedCalled = true
    }
}
