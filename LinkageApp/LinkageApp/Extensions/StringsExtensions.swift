//
//  StringsExtension.swift
//  LinkageApp

//  Created by cuonghx on 5/4/19.
//  Copyright © 2019 cuonghx. All rights reserved.
//

import Foundation

extension String {
    func getAgeFromDateString() -> Int? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy"
        let calender = Calendar.current
        if let date = dateFormatterGet.date(from: self) {
            return calender.dateComponents([.year],
                                           from: date ,
                                           to: Date()).year
        }
        return nil
    }
}
