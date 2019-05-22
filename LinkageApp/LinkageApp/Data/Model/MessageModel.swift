//
//  MessageModel.swift
//  LinkageApp
//
//  Created by cuonghx on 5/17/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import ObjectMapper

struct MessageModel {
    var user: [String]
    var isConnected: Bool
    var id: String
    var listMessage: [MessageItemModel]
}

extension MessageModel {
    init() {
        self.init(user: [],
                  isConnected: false,
                  id: "",
                  listMessage: [])
    }
    
    init(fromUID: String, toUID: String) {
        self.init(user: [fromUID, toUID],
                  isConnected: false,
                  id: "",
                  listMessage: [])
    }
}

extension MessageModel: Mappable {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        user <- map["users"]
        isConnected <- map ["isConnected"]
    }
}
