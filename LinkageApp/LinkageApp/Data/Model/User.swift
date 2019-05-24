//
//  User.swift
//  LinkageApp
//
//  Created by cuonghx on 5/5/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import ObjectMapper

struct User {    
    var uid: String
    var name: String
    var urlImage: String
    var job: String
    var hobbies: String
    var description: String
    var dob: String
    var isMale: Bool
}

extension User {
    init() {
        self.init(
            uid: "",
            name: "",
            urlImage: "",
            job: "",
            hobbies: "",
            description: "",
            dob: "",
            isMale: true)
    }
}
extension User: Mappable {
    
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        self.uid <- map["uid"]
        self.name <- map["name"]
        self.urlImage <- map["urlImage"]
        self.job <- map["job"]
        self.hobbies <- map["hobbies"]
        self.description <- map["description"]
        self.dob <- map["dob"]
        self.isMale <- map["gender"]
    }
    
}
