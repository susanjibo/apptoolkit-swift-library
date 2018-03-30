//
//  Camera.swift
//  AppToolkit
//
//  Created by Alex Zablotskiy on 10/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

//MARK: Camera

/// Enum of Jibo's two cameras
public enum Camera: String {
	/** Use `left` for photo taking */
	case left = "left"
	/** `right` camera reserved for tracking. */
	case right = "right"
}

/**
 Camera resolution options
 */
public enum CameraResolution: String {
	/** Currently unsupported. */
	case high = "highRes"
	/** Better quality than default */
	case medium = "medRes"
	/** Default */
	case low = "lowRes"
	/** Lower quality than default */
	case micro = "microRes"
}

/**
 Type of video stream to get
 */
public enum VideoType: String {
	/** Default */
	case normal = "NORMAL"
	/** Currently unsupported */
	case debug = "DEBUG"
}
