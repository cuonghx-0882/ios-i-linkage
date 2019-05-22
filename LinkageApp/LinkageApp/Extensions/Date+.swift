//
//  Date+.swift
//  LinkageApp
//
//  Created by cuonghx on 5/18/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

extension Date {
    func toString(dateFormat format: String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
