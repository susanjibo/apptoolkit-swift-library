//
//  EventType.swift
//  AppToolkit
//
//  Created by Justin Shiiba on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

//MARK: Events
/// Enum of events
public enum EventType: String {
    case undefined  = ""

    // MARK: - Async Events
    /// async event
    case asyncStart         = "onStart"
    /// async event
    case asyncStop          = "onStop"
    /// async event
    case asyncError         = "onError"

    // MARK: - Entity Events
    /// Entity being tracked moved
    case trackUpdate        = "onEntityUpdate"
    /// Lost entity being tracked 
    case trackLost          = "onEntityLost"
    /// Found an entity to track
    case trackGained        = "onEntityGained"

    // MARK: - LookAt Events
    /// Jibo looked at the spot he was told to look at
    case lookAtAchieved     = "onLookAtAchieved"
    /// Lost person being tracked
    case trackEntityLost    = "onTrackEntityLost"

    // MARK: - Other Events
    /// URL to video is ready to stream
    case videoReady         = "onVideoReady"
    /// Emitted when a photo is taken
    case takePhoto          = "onTakePhoto"
    
    // MARK: - Display events
    /// View state has changed
    case viewStateChange    = "onViewStateChange"
    
    // MARK: - Motion events
    /// Jibo detected movement.
    case motionDetected     = "onMotionDetected"

    // MARK: - HeadTouch events
    /// Jibo received a head touch.
    case headTouched        = "onHeadTouch"
    
    // MARK: - Listen events
    /// Jibo heard "Hey Jibo." Unsupported
    case onHotWordHeard     = "onHotWordHeard"
    /// Jibo got a result back from listening
    case listenResult       = "onListenResult"
    /// Jibo stopped listening
    case listenStop         = "onListenStop"

    // MARK: - FetchAsset events
    /// The asset is ready to display
    case assetReady         = "onAssetReady"
    /// The asset could not be fetched
    case assetFailed        = "onAssetFailed"

    // MARK: - Config events
    /// A configuration option changed.
    case onConfig           = "onConfig"
    
    // MARK: - Screen gesture events
    /// Jibo's screen was tapped
    case onScreenTap        = "onTap"
    /// Jibo's screen was swiped
    case onScreenSwipe      = "onSwipe"

}
