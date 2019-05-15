//
//  Location.swift
//  LinkageApp
//
//  Created by cuonghx on 5/12/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import ObjectMapper

struct Location {
    var lat: Double
    var long: Double
    var distance: Double
}

extension Location {
    init() {
        self.init(lat: 0,
                  long: 0,
                  distance: 0)
    }
    
    init(lat: Double, long: Double) {
        self.init(lat: lat,
                  long: long,
                  distance: 0)
    }
}

extension Location: Mappable {
    init?(map: Map) {
        self.init()
    }
    
    mutating func mapping(map: Map) {
        lat <- map["lat"]
        long <- map["long"]
    }
}
