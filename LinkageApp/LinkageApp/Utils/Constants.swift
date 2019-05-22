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
    static let sendGreetingMS = "Enter the greeting message"
    static let sendGRMSTitle = "Send a greeting message"
    static let messageEmpty = "This message cannot be empty"
    static let mesageRequest = " sent you a message, Do you want to connect with them"
    static let limitedAge = "You must be 14 years old or above"
    static let editDOB = "Click to Edit Date Of Birth"
}

enum Title {
    static let descriptionTT = "Description: "
    static let jobTT = "Job: "
    static let hobbiesTT = "Hobbies: "
    static let justNow = "Just now"
    static let addnewData = "Click edit icon to add new data"
}

enum ButtonTitle {
    static let gpsGotoSettingLC = "Go to Settings now"
    static let back = "Back"
    static let send = "Send"
    static let goProfile = "Go to Profile"
}

enum TitleScreen {
    static let searchByDistanceScreen = "Seach by Distance"
    static let requestScren = "Request"
    static let chatScreen = "Chat"
    static let profile = "Profile"
    static let edit = "Edit"
}
