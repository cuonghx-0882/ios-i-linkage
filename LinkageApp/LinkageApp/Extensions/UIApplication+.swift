//
//  Application+.swift
//  LinkageApp
//
//  Created by cuonghx on 5/10/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import Foundation

extension UIApplication {
    class func getPresentedViewController() -> UIViewController? {
        var presentViewController = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentViewController?.presentedViewController {
            presentViewController = pVC
        }
        return presentViewController
    }
}
