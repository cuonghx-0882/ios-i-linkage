//
//  AppDelegate.swift
//  LinkageApp
//
//  Created by cuonghx on 5/4/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configApp()
        return true
    }
    
    private func configApp() {
        FirebaseApp.configure()
        window = window ?? UIWindow()
        let rootVC = LoginViewController.instantiate()
        let nav = UINavigationController().then {
            $0.isNavigationBarHidden = true
        }
        nav.pushViewController(rootVC, animated: false)
        window?.do {
            $0.rootViewController = nav
            $0.makeKeyAndVisible()
        }
    }
}
