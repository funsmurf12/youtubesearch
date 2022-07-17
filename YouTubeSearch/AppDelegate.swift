//
//  AppDelegate.swift
//  YouTubeSearch
//
//  Created by Kiet Nguyen on 7/17/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: YoutubeSearchViewController())
        window?.makeKeyAndVisible()
        return true
    }
}

