//
//  UIScrollView+.swift
//  LinkageApp
//
//  Created by cuonghx on 5/25/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

extension UIScrollView {
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0,
                                   y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
}
