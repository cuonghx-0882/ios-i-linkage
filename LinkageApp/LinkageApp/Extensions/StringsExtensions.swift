//
//  Strings.swift
//  P1
//
//  Created by cuonghx on 5/4/19.
//  Copyright © 2019 cuonghx. All rights reserved.
//

import Foundation

extension String {
    func isValidateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
