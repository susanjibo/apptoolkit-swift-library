//
//  Display.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 12/4/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
//MARK: Display
/**
 Display enum
 */
enum DisplayViewType: String {
    /** undefined */
    case undefined = ""
    /** eye */
    case eye = "Eye"
    /** text */
    case text = "Text"
    /** image */
    case image = "Image"
}

/**
 Display view state enum
 */
public enum DisplayViewState: String {
    /** opened */
    case opened = "Opened"
    /** closed */
    case closed = "Closed"
}

