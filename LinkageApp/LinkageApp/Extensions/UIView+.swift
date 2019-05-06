//
//  UIView+.swift
//  LinkageApp
//
//  Created by cuonghx on 5/4/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
