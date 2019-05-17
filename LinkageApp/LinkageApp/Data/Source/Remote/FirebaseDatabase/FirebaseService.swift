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
    
}

// MARK: - User
extension FirebaseService {
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
}

// MARK: - Location
extension FirebaseService {
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

// MARK: - Message Method
extension FirebaseService {
    func sendMessageRequest(content: String,
                            fromID: String,
                            toID: String,
                            completion: @escaping (Error?) -> Void) {
        ref.child(KeyFirebaseDatabase.message)
            .observeSingleEvent(of: .value) { (snap) in
                var alreadyExist: MessageModel?
                for item in snap.children {
                    if let snapshot = item as? DataSnapshot,
                        let value = snapshot.value as? [String: Any],
                        var message = MessageModel(JSON: value),
                        message.user.index(of: fromID) != nil,
                        message.user.index(of: toID) != nil {
                        message.id = snapshot.key
                        alreadyExist = message
                        break
                    }
                }
                if let message = alreadyExist,
                    message.user.first == fromID {
                    completion(ErrorCustom.alreadyRequest)
                } else if alreadyExist != nil {
                    completion(ErrorCustom.alreadyRequesInList)
                } else {
                    let messageModel = MessageModel(fromUID: fromID,
                                                    toUID: toID)
                    self.ref.child(KeyFirebaseDatabase.message)
                        .childByAutoId()
                        .setValue(messageModel.toJSON(), withCompletionBlock: { (err, dbref) in
                            if let key = dbref.key {
                                self.sendMessage(content: content,
                                                 messeageID: key,
                                                 fromID: fromID,
                                                 completion: completion)
                            } else {
                                completion(err)
                            }
                        })
                }
            }
    }
    
    func sendMessage(content: String,
                     messeageID: String,
                     fromID: String,
                     completion: @escaping (Error?) -> Void ) {
        var message = MessageItemModel(content: content,
                                       date: 0,
                                       fromID: fromID,
                                       isActive: true).toJSON()
        message["date"] = ServerValue.timestamp()
        ref.child(KeyFirebaseDatabase.message)
            .child(messeageID)
            .child(KeyFirebaseDatabase.message)
            .childByAutoId()
            .setValue(message) { (err, _ ) in
                completion(err)
            }
    }
}
