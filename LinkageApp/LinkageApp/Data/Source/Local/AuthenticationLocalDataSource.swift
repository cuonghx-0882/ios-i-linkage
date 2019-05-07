//
//  AuthenticationLocalDataSource.swift
//  LinkageApp
//
//  Created by cuonghx on 5/5/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

protocol AuthenticationLocalDataSource {
    func saveUser(user: User)
    func getuser() -> User?
    func removeUser()
}

final class AuthenticationLocalDataSourceIml: AuthenticationLocalDataSource {
    
    private var user: User!
    
    private init () {}
    
    class var sharedInstance: AuthenticationLocalDataSource {
        enum Static {
            static let instance = AuthenticationLocalDataSourceIml()
        }
        return Static.instance
    }
    
    func saveUser(user: User) {
        self.user = user
        let preferences = UserDefaults.standard
        preferences.set(user.uid, forKey: UserKey.uid.rawValue)
        preferences.set(user.name, forKey: UserKey.name.rawValue)
        preferences.set(user.urlImage, forKey: UserKey.urlImage.rawValue)
        preferences.set(user.hobbies, forKey: UserKey.hobbies.rawValue)
        preferences.set(user.description, forKey: UserKey.description.rawValue)
        preferences.set(user.dob, forKey: UserKey.dob.rawValue)
        preferences.set(user.gender, forKey: UserKey.gender.rawValue)
        preferences.set(user.job, forKey: UserKey.job.rawValue)
        preferences.synchronize()
    }
    
    func getuser() -> User? {
        if self.user != nil {
            return self.user
        }
        let preferences = UserDefaults.standard
        guard let uid = preferences.object(forKey: UserKey.uid.rawValue) as? String,
        let name = preferences.object(forKey: UserKey.name.rawValue) as? String,
        let urlImage = preferences.object(forKey: UserKey.urlImage.rawValue) as? String,
        let job = preferences.object(forKey: UserKey.job.rawValue) as? String,
        let hobbies = preferences.object(forKey: UserKey.hobbies.rawValue) as? String,
        let description = preferences.object(forKey: UserKey.description.rawValue) as? String,
        let dob = preferences.object(forKey: UserKey.dob.rawValue) as? String,
        let gender = preferences.object(forKey: UserKey.gender.rawValue) as? Bool
        else {
            return nil
        }
        self.user = User(uid: uid,
                         name: name,
                         urlImage: urlImage,
                         job: job,
                         hobbies: hobbies,
                         description: description,
                         dob: dob,
                         gender: gender)
        return self.user
    }
    
    func removeUser() {
        self.user = nil
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: UserKey.uid.rawValue)
        preferences.removeObject(forKey: UserKey.name.rawValue)
        preferences.removeObject(forKey: UserKey.urlImage.rawValue)
        preferences.removeObject(forKey: UserKey.hobbies.rawValue)
        preferences.removeObject(forKey: UserKey.description.rawValue)
        preferences.removeObject(forKey: UserKey.dob.rawValue)
        preferences.removeObject(forKey: UserKey.gender.rawValue)
        preferences.removeObject(forKey: UserKey.job.rawValue)
        preferences.synchronize()
    }
}

enum UserKey: String {
    case uid
    case name
    case urlImage
    case job
    case hobbies
    case description
    case dob
    case gender
}
