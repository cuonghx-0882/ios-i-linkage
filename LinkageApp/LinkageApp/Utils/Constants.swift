//
//  AppConstant.swift
//  Structure_IOS
//
//  Created by DaoLQ on 10/21/17.
//  Copyright © 2017 DaoLQ. All rights reserved.
//

import Foundation

enum Constants {
    static let appName = "Linkage App"
}

enum Message {
    static let checkNetworkingMS = "Please check your internet connection"
    static let invalidEmailOrPasswordMS = "You have entered an invalid email or password"
    static let emailNotValidMS = "This email address is not valid"
    static let enterValidEmailMS = "Please enter a valid address"
    static let errorWithAccountMS = "Error with your account"
    static let contactToOurMS = "Please contact our support team"
    static let enterEmailMS = "Enter your email address"
    static let successMS = "Success !"
    static let checkYEmailMS = "Please check your email address"
    static let userNotFoundMS = "User not Found"
    static let passwordEmptyMS = "Password field is empty"
    static let confirmPasswordNotMatchMS = "Your password and confirmation password do not match"
    static let nameFieldNullMS = "Name field is empty"
    static let dobFieldNullMS = "Date of birth field is empty"
    static let dobFieldNotValid = "Invalid date format. Please enter the date in the format \"dd-MM-yyyy\""
    static let slOtherImageMS = "Select other image"
    static let slAnImageMS = "Select an image to continue"
    static let emailFieldNullMS = "Email field is empty"
    static let gpsAccessTitle = "GPS access is restricted"
    static let gpsAccessMS = "Please enable GPS in the Settigs app under Privacy, Location Services"
    static let gpsAccessDeniedTitle = "GPS access is denied"
    static let gpsAccessDeniedMS = "Please select Always or While Using the App"
    static let filterNotValidate = "Filter not validate"
    static let filterNotValidateMS = "Your age field or distance field not validate"
}

enum ButtonTitle {
    static let gpsGotoSettingLC = "Go to Settings now"
}

enum TitleScreen {
    static let searchByDistanceScreen = "Seach by Distance"
}
