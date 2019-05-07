//
//  UserRepository.swift
//  LinkageApp
//
//  Created by cuonghx on 5/8/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import FirebaseAuth

protocol UserRepositoryType {
    func signIn(email: String, password: String, completion callback: @escaping (User?, Error?) -> Void)
    func signUp()
    func logout()
    func forgot(email: String, completion: @escaping (Error?) -> Void)
}

final class UserRepository: UserRepositoryType {
    
    static var shared: UserRepositoryType {
        enum Static {
            static let instance = UserRepository()
        }
        return Static.instance
    }
    
    func signIn(email: String, password: String, completion callback: @escaping (User?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            if let uid = result?.user.uid {
                FirebaseService.share.getUserFromUID(uid: uid, completion: { (user, err) in
                    callback(user, err)
                })
            } else {
               callback(nil, err)
            }
        }
    }
    
    func signUp() { }
    
    func logout() { }
    
    func forgot(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            completion(err)
        }
    }
}
