//
//  Validation.swift
//  LinkageApp
//
//  Created by cuonghx on 5/8/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

enum Validation {
    static func isValidateEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    static func isValidateDate(date: String) -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy"
        if dateFormatterGet.date(from: date) != nil {
            return true
        } else {
            return false
        }
    }
}
