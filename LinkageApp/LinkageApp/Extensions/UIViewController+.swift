//
//  UIViewController+.swift
//  LinkageApp
//
//  Created by cuonghx on 5/4/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

extension UIViewController {
    func showError(message: String?, completion: (() -> Void)? = nil) {
        let alertc = UIAlertController(title: "Error",
                                       message: message,
                                       preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            completion?()
        }
        alertc.addAction(okAction)
        present(alertc, animated: true, completion: nil)
    }
}
