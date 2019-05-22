//
//  UILabel+.swift
//  LinkageApp
//
//  Created by cuonghx on 5/16/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

extension UILabel {
    
    var isTruncated: Bool {
        guard let labelText = text else {
            return false
        }
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size
        return labelTextSize.height > bounds.size.height
    }
}
