//
//  Connectivity.swift
//  LinkageApp
//
//  Created by cuonghx on 5/15/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import Alamofire

enum Connectivity {
    private static let sharedInstance = NetworkReachabilityManager()
    static var isConnectedToInternet: Bool {
        if let shared = sharedInstance {
            return shared.isReachable
        }
        return false
    }
}
