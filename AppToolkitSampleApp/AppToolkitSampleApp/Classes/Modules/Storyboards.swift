//
//  Storyboards.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit

enum Storyboards: String {
	case main = "Main"
	
	var storyboard: UIStoryboard {
		return UIStoryboard(name: rawValue, bundle: nil)
	}
}
