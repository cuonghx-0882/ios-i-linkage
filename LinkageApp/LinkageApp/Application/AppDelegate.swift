//
//  AppDelegate.swift
//  LinkageApp
//
//  Created by cuonghx on 5/4/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = window ?? UIWindow()
        let rootVC = LoginViewController.instantiate()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
}
