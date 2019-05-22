//
//  StringsExtension.swift
//  LinkageApp

//  Created by cuonghx on 5/4/19.
//  Copyright © 2019 cuonghx. All rights reserved.
//

import MessengerKit

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
    
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
    
    var containsOnlyEmoji: Bool {
        return !isEmpty && !unicodeScalars.contains(where: {
            !$0.isEmoji && !$0.isZeroWidthJoiner
        })
    }
    
    var convertMSBody: MSGMessageBody {
        return (self.containsOnlyEmoji && self.count < 5) ? .emoji(self)
            : .text(self)
    }
}
