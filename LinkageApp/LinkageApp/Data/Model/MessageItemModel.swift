//
//  MessageItemModel.swift
//  LinkageApp
//
//  Created by cuonghx on 5/17/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import ObjectMapper

struct MessageItemModel {
    var content: String
    var date: Double
    var fromID: String
    var isActive: Bool
}

extension MessageItemModel {
    init() {
        self.init(content: "",
                  date: 0,
                  fromID: "",
                  isActive: false)
    }
}

extension MessageItemModel: Mappable {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        content <- map["content"]
        date <- map["date"]
        fromID <- map["fromID"]
        isActive <- map["isActive"]
    }
}
