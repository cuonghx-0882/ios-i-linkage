//
//  UserMS.swift
//  LinkageApp
//
//  Created by cuonghx on 5/18/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

import MessengerKit

struct UserChat: MSGUser {
    var displayName: String
    var avatar: UIImage?
    var isSender: Bool
}

extension UserChat {
    init(displayName: String, isSender: Bool) {
        self.init(displayName: displayName,
                  avatar: nil,
                  isSender: isSender)
    }
}
