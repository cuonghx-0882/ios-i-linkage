//
//  UIViewController+.swift
//  LinkageApp
//
//  Created by cuonghx on 5/4/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import SVProgressHUD

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func progessAnimation(_ show: Bool) {
        if show {
            SVProgressHUD.show()
            view.isUserInteractionEnabled = false
            view.alpha = 0.5
        } else {
            SVProgressHUD.dismiss()
            view.isUserInteractionEnabled = true
            view.alpha = 1
        }
    }
}
