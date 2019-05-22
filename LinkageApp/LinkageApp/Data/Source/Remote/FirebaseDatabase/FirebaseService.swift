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
    
    func getMessagePaging(messageID: String,
                          fromDate: Double,
                          numberLimited: UInt,
                          completion: @escaping ([MessageItemModel], Error?) -> Void) {
        ref.child(KeyFirebaseDatabase.message)
            .child(messageID)
            .child(KeyFirebaseDatabase.message)
            .queryOrdered(byChild: "date")
            .queryLimited(toLast: numberLimited)
            .queryEnding(atValue: fromDate)
            .observeSingleEvent(of: .value,
                                with: { (snapshot) in
                                    var messages = [MessageItemModel]()
                                    for snap in snapshot.children {
                                        if let snap = snap as? DataSnapshot,
                                            let value = snap.value as? [String: Any],
                                            let mess = MessageItemModel(JSON: value) {
                                            messages.append(mess)
                                        }
                                    }
                                    completion(messages, nil)
            }, withCancel: { (err) in
                completion([], err)
            })
    }
    
    func listenMessage(messageID: String, callback: @escaping(Error?, MessageItemModel?) -> Void) {
        ref.child(KeyFirebaseDatabase.message)
            .child(messageID)
            .child(KeyFirebaseDatabase.message)
            .queryOrdered(byChild: "date")
            .queryStarting(atValue: Date().timeIntervalSince1970.convertToTimeIntervalFirebase)
            .queryLimited(toLast: 1)
            .observe(.childAdded,
                     with: { (snap) in
                        if let value = snap.value as? [String: Any] {
                            callback (nil, MessageItemModel(JSON: value))
                        }
                        callback(nil, nil)
            }, withCancel: { (err) in
                callback(err, nil)
            })
    }
}

// MARK: - Request Method
extension FirebaseService {
    
    func connectMessage(messageID: String, completion: @escaping(Error?) -> Void) {
        ref.child(KeyFirebaseDatabase.message)
            .child(messageID)
            .child("isConnected")
            .setValue(true) { (err, _) in
                completion(err)
            }
    }
    
    func getListMessage(uid: String,
                        connected: Bool,
                        completion: @escaping([MessageItemListModel], Error?) -> Void) {
        ref.child(KeyFirebaseDatabase.message)
            .queryOrdered(byChild: "isConnected")
            .queryEqual(toValue: connected)
            .observeSingleEvent(of: .value,
                                with: { (snapshot) in
                                    var result = [MessageItemListModel]()
                                    let dispathGroup = DispatchGroup()
                                    for snap in snapshot.children {
                                        if let snap = snap as? DataSnapshot,
                                            let value = snap.value as? [String: Any],
                                            var mes = MessageModel(JSON: value),
                                            (mes.user.last == uid && !connected) ||
                                                (mes.user.index(of: uid) != nil && connected),
                                            var fromUser = mes.user.first {
                                            mes.id = snap.key
                                            let date = Date().timeIntervalSince1970
                                                .convertToTimeIntervalFirebase
                                            dispathGroup.enter()
                                            let dispathGroupChild = DispatchGroup()
                                            dispathGroupChild.enter()
                                            var user: User?
                                            var message: MessageItemModel?
                                            self.getMessagePaging(messageID: snap.key,
                                                                  fromDate: date,
                                                                  numberLimited: 1,
                                                                  completion: { (mes, _) in
                                                                    message = mes.first
                                                                    dispathGroupChild.leave()
                                            })
                                            dispathGroupChild.enter()
                                            if let last = mes.user.last, last != uid {
                                                fromUser = last
                                            }
                                            self.getUserFromUID(uid: fromUser ,
                                                                completion: { (u, _) in
                                                                    user = u
                                                                    dispathGroupChild.leave()
                                            })
                                            dispathGroupChild.notify(queue: .main, execute: {
                                                if let user = user,
                                                    let message = message {
                                                    let item = MessageItemListModel(user: user,
                                                                                    messagelast: message,
                                                                                    messageModel: mes)
                                                    result.append(item)
                                                }
                                                dispathGroup.leave()
                                            })
                                        }
                                    }
                                    dispathGroup.notify(queue: .main, execute: {
                                        completion(result, nil)
                                    })
            }, withCancel: { (err) in
                completion([], err)
            })
    }
}

// MARK: - Update
extension FirebaseService {
    func updateProfileforKey(userID: String,
                             key: String,
                             value: Any,
                             completion:@escaping (Error?) -> Void) {
        ref.child(KeyFirebaseDatabase.usersDatabase)
            .child(userID)
            .child(key)
            .setValue(value) { (err, _) in
                completion(err)
            }
    }
}
