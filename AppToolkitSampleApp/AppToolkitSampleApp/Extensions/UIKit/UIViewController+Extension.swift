//
//  UIViewController+Extension.swift
//  AppToolkitSampleApp
//
//  Created by Alex Zablotskiy on 10/3/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import UIKit

extension UIViewController {
	
	class func controller(from storyboards: Storyboards) -> Self {
		return controller(in: storyboards.storyboard, identifier: nameOfClass)
	}
	
	class func controller(in storyboard: UIStoryboard, identifier: String) -> Self {
		return instantiateControllerInStoryboard(storyboard, identifier: identifier)
	}
	
	fileprivate class func instantiateControllerInStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, identifier: String) -> T {
		return storyboard.instantiateViewController(withIdentifier: identifier) as! T
	}
	
}
