//
//  FirebaseService.swift
//  LinkageApp
//
//  Created by cuonghx on 5/6/19.
//  Copyright © 2019 Sun*. All rights reserved.
//
import FirebaseDatabase

struct FirebaseService {
    
    static let share = FirebaseService()
    
    private var ref = Database.database().reference()
    
    func getUserFromUID(uid: String, completion : @escaping (User?, Error?) -> Void ) {
        ref.child("users").child(uid).observeSingleEvent(of: .value,
                                                         with: { (snap) in
            if let value = snap.value as? [String: Any] {
                completion(User(JSON: value), nil)
            } else {
                completion(nil, nil)
            }
        }, withCancel: { (err) in
            completion(nil, err)
        })
    }
    
    func saveUser(user: User, completion : @escaping (Error?) -> Void) {
        ref.child("users").child(user.uid).setValue(user.toJSON()) { ( err, _ ) in
            completion(err)
        }
    }
    
    func removeUser(uid: String, completion : @escaping (Error?) -> Void) {
        ref.child("users").child(uid).setValue(nil) { ( err, _ ) in
            completion(err)
        }
    }
}
