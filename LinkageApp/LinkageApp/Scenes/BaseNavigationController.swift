//
//  BaseNavigationController.swift
//  LinkageApp
//
//  Created by cuonghx on 5/6/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

// swiftlint:disable final_class
class BaseNavigationController: UINavigationController, AlertViewController {
    deinit {
        logDeinit()
    }
}
// swiftlint:enable final_class
