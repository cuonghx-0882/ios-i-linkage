//
//  ModelFaceNet.swift
//  LinkageApp
//
//  Created by cuonghx on 5/24/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import ObjectMapper

struct ModelFaceNet {
    var vector: [[Double]]
    var distance: Double
    var user: User?
}

extension ModelFaceNet {
    init() {
        self.init(vector: [],
                  distance: 0,
                  user: nil)
    }
}

extension ModelFaceNet: Mappable {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        vector <- map["vector"]
    }
}
