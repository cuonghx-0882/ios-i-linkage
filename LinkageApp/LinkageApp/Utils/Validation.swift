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
        return dateFormatterGet.date(from: date) != nil 
    }
    
    static func checkValidateSignIn(email: String,
                                    password: String,
                                    confirmPassword: String,
                                    name: String,
                                    dob: String) -> Bool {
        if let vc = UIApplication.getPresentedViewController() {
            if email.isEmpty {
                vc.showErrorAlert(errMessage: Message.emailFieldNullMS)
                return false
            }
            if !Validation.isValidateEmail(email: email) {
                vc.showErrorAlert(errMessage: Message.emailNotValidMS)
                return false
            }
            if password.isEmpty {
                vc.showErrorAlert(errMessage: Message.passwordEmptyMS)
                return false
            }
            if confirmPassword != password {
                vc.showErrorAlert(errMessage: Message.confirmPasswordNotMatchMS)
                return false
            }
            if name.isEmpty {
                vc.showErrorAlert(errMessage: Message.nameFieldNullMS)
                return false
            }
            if dob.isEmpty {
                vc.showErrorAlert(errMessage: Message.dobFieldNullMS)
                return false
            }
            if !Validation.isValidateDate(date: dob) {
                vc.showErrorAlert(errMessage: Message.dobFieldNotValid)
                return false
            }
        }
        return true
    }
}
