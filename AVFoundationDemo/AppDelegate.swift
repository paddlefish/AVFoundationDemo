//
//  AppDelegate.swift
//  AVFoundationDemo
//
//  Created by Andrew Rahn on 3/11/18.
//  Copyright © 2018 Andrew Rahn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		window = UIWindow(frame: UIScreen.main.bounds)
		
		let nc = UINavigationController(rootViewController: ViewController())
		window?.rootViewController = nc
		window?.makeKeyAndVisible()
		
		return true
	}

}

