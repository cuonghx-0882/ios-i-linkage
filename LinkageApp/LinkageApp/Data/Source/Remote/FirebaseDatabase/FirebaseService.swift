//
//  FirebaseService.swift
//  LinkageApp
//
//  Created by cuonghx on 5/6/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import FirebaseDatabase
import CoreLocation

struct FirebaseService {
    
    static let share = FirebaseService()
    
    private var ref = Database.database().reference()
    
    private init () { }
    
    // MARK: - Method
    func getUserFromUID(uid: String, completion : @escaping (User?, Error?) -> Void ) {
        let userKey = KeyFirebaseDatabase.usersDatabase
        ref.child(userKey)
            .child(uid)
            .observeSingleEvent(of: .value,
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
        ref.child(KeyFirebaseDatabase.usersDatabase).child(user.uid).setValue(user.toJSON()) { ( err, _ ) in
            completion(err)
        }
    }
    
    func removeUser(uid: String, completion : @escaping (Error?) -> Void) {
        ref.child(KeyFirebaseDatabase.usersDatabase).child(uid).setValue(nil) { ( err, _ ) in
            completion(err)
        }
    }
    
    func pushLocation(uid: String, location: Location, completion: @escaping (Error?) -> Void) {
        let locationKey = KeyFirebaseDatabase.locationDatabase
        ref.child(locationKey).child(uid).setValue(location.toJSON()) { (err, _ ) in
            completion(err)
        }
    }
    
    func getAllLocation(currentLocation: Location,
                        completion: @escaping ([ModelCellResult], Error?) -> Void) {
        let locationKey = KeyFirebaseDatabase.locationDatabase
        ref.child(locationKey)
            .observe(.value,
                     with: { (snap) in
                        var results = [ModelCellResult]()
                        let dispathGroup = DispatchGroup()
                        for item in snap.children {
                            if let snapshot = item as? DataSnapshot,
                                let value = snapshot.value as? [String: Any],
                                var location = Location(JSON: value) {
                                let coordinate = CLLocation(latitude: location.lat,
                                                            longitude: location.long)
                                let currentCD = CLLocation(latitude: currentLocation.lat,
                                                           longitude: currentLocation.long)
                                location.distance = coordinate.distance(from: currentCD)
                                dispathGroup.enter()
                                self.getUserFromUID(uid: snapshot.key,
                                                    completion: { (user, _ ) in
                                                        if let user = user {
                                                            let result = ModelCellResult(user: user,
                                                                                         location: location)
                                                            results.append(result)
                                                        }
                                                        dispathGroup.leave()
                                })
                            }
                        }
                        dispathGroup.notify(queue: .main, execute: {
                            completion(results, nil)
                        })
            }, withCancel: { (err) in
                completion([], err)
            })
    }
}
