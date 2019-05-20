//
//  ErrorCustom.swift
//  LinkageApp
//
//  Created by cuonghx on 5/17/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

enum ErrorCustom: LocalizedError {
    case alreadyRequest
    case alreadyRequesInList

    var errorDescription: String? {
        switch self {
        case .alreadyRequest:
            return "The message has been sent"
        case .alreadyRequesInList :
            return "Their requests are waiting on your request list"
        }
    }
}
