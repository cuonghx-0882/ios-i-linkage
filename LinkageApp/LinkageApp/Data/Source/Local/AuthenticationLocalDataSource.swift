//
//  AuthenticationLocalDataSource.swift
//  LinkageApp
//
//  Created by cuonghx on 5/5/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import ObjectMapper

protocol AuthenticationLocalDataSource {
    func saveUser(user: User)
    func getUser() -> User?
    func removeUser()
}

final class AuthManagerLocalDataSource: AuthenticationLocalDataSource {
    
    private var user: User! {
        didSet {
            if user == nil {
                preferences.removeObject(forKey: key)
            } else {
                preferences.set(user.toJSON(), forKey: key)
            }
            preferences.synchronize()
        }
    }
    private let key = "UserLocalKey"
    private var preferences = UserDefaults.standard
    
    private init () {}
    
    static var shared: AuthenticationLocalDataSource {
        enum Static {
            static let instance = AuthManagerLocalDataSource()
        }
        return Static.instance
    }
    
    func saveUser(user: User) {
        self.user = user
    }
    
    func getUser() -> User? {
        if self.user != nil {
            return self.user
        }
        guard let json = preferences.value(forKey: key) as? [String: Any] else {
            return nil
        }
        self.user = User(JSON: json)
        return self.user
    }
    
    func removeUser() {
        self.user = nil
    }
}
