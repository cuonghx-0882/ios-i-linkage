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
    
    static func checkValidateFilter(filter: Filter) -> Bool {
        let ageFrom = Int(filter.ageFrom) ?? 0
        let distanceFrom = Int(filter.distanceFrom) ?? 0
        let ageTo = Int(filter.ageTo) ?? Int.max
        let distanceTo = Int(filter.distanceTo) ?? Int.max
        return ageFrom <= ageTo && distanceFrom <= distanceTo
    }
    
    static func modelValidateWithFilter(model: ModelCellResult, filter: Filter) -> Bool {
        switch filter.gender {
        case 1:
            if !model.user.isMale { return false }
        case 2:
            if model.user.isMale { return false }
        default:
            break
        }
        let fromDistance = filter.distanceFrom.isEmpty ? "" : filter.distanceFrom.appending("000")
        let toDistance = filter.distanceTo.isEmpty ? "" : filter.distanceTo.appending("000")
        if !Validation.checkValidateNumberInRange(number: model.user.dob.getAgeFromDateString(),
                                                  min: filter.ageFrom,
                                                  max: filter.ageTo) ||
            !Validation.checkValidateNumberInRange(number: Int(model.location.distance),
                                                   min: fromDistance,
                                                   max: toDistance) {
            return false
        }
        if !filter.enable100km,
            model.location.distance > 100.0.tom {
            return false
        }
        return true
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
            if let age = dob.getAgeFromDateString(), age < 14 {
                vc.showErrorAlert(errMessage: Message.limitedAge)
            }
        }
        return true
    }
    
    static func checkInRange(number: Int, min: Int, max: Int) -> Bool {
        return number <= max && number >= min
    }
    
    static func lessThanOrEqual(number: Int, with: Int) -> Bool {
        return number <= with
    }
    
    static func moreThanOrEqual(number: Int, with: Int) -> Bool {
        return number >= with
    }
    
    static func checkValidateNumberInRange(number: Int?, min: String, max: String) -> Bool {
        if let number = number {
            if min.isEmpty,
                let numberTo = Int(max),
                !Validation.lessThanOrEqual(number: number,
                                            with: numberTo) {
                return false
            } else if max.isEmpty,
                let numberFrom = Int(min),
                !Validation.moreThanOrEqual(number: number,
                                            with: numberFrom) {
                return false
            } else if let numberFrom = Int(min),
                let numberTo = Int(max),
                !Validation.checkInRange(number: number,
                                         min: numberFrom,
                                         max: numberTo) {
                return false
            }

        } else if !min.isEmpty || !max.isEmpty {
            return false
        }
        return true
    }
    
    static func modelValidateWithFilter(model: ModelFaceNet, filter: Filter) -> Bool {
        
        guard let user = model.user else {
            return false
        }
        switch filter.gender {
        case 1:
            if !user.isMale { return false }
        case 2:
            if user.isMale { return false }
        default:
            break
        }
        let fromDistance = filter.distanceFrom.isEmpty ? "" : filter.distanceFrom
        let toDistance = filter.distanceTo.isEmpty ? "" : filter.distanceTo
        if !Validation.checkValidateNumberInRange(number: user.dob.getAgeFromDateString(),
                                                  min: filter.ageFrom,
                                                  max: filter.ageTo) ||
            !Validation.checkValidateNumberInRange(number: Int(model.distance.toPercent),
                                                   min: fromDistance,
                                                   max: toDistance) {
            return false
        }
        return true
    }
}
