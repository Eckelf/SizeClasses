//
//  AppDelegate.swift
//  SizeClasses
//
//  Created by Vincent Flecke on 2017-08-15.
//  Copyright (c) 2017 Vincent Flecke. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = ViewController(nibName: nil, bundle: nil)
        
        window!.makeKeyAndVisible()
        
        return true
    }
    
}
