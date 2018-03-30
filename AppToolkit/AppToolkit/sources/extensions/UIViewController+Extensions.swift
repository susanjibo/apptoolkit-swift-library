//
//  UIViewController+Extensions.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/17/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

extension UIViewController {
    
    static func topViewController() -> UIViewController? {
        return topViewController(withRoot: UIApplication.shared.keyWindow?.rootViewController)
    }
    
    static func topViewController(withRoot root: UIViewController?) -> UIViewController? {
        if let newRoot = (root as? UITabBarController)?.selectedViewController {
            return topViewController(withRoot: newRoot)
        }
        
        if let newRoot = (root as? UINavigationController)?.visibleViewController {
            return topViewController(withRoot: newRoot)
        }
        
        if let newRoot = root?.presentedViewController {
            return topViewController(withRoot: newRoot)
        }
        
        return root
    }
}

extension UIViewController {
    func viewWillDisappearSignal() -> Signal<(), NoError> {
        return reactive.trigger(for: #selector(UIViewController.viewWillDisappear(_:)))
    }
    
    func viewWillAppearSignal() -> Signal<(), NoError> {
        return reactive.trigger(for: #selector(UIViewController.viewWillAppear(_:)))
    }
    
    func dismissViewControllerAnimatedSignal() -> Signal<(), NoError> {
        return reactive.trigger(for: #selector(UIViewController.dismiss))
    }
    
    func removeFromParentViewControllerSignal() -> Signal<(), NoError> {
        return reactive.trigger(for: #selector(UIViewController.removeFromParentViewController))
    }
    
    internal var viewWillDisappearSignalProducer: SignalProducer<(), NoError>  {
        return SignalProducer(self.viewWillDisappearSignal())
    }
    
    internal var viewWillAppearSignalProducer: SignalProducer<(), NoError>  {
        return SignalProducer(self.viewWillAppearSignal())
    }
}
