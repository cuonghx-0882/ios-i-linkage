//
//  File.swift
//  LinkageApp
//
//  Created by cuonghx on 5/14/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

// swiftlint:disable number_separator
extension Double {
    var tokm: Double {
        return self / 1000.0
    }
    var tom: Double {
        return self * 1000.0
    }
    var convertToTimeIntervalFirebase: Double {
        return self * 1000
    }
    var convertTimeIntervalFromFirebase: Double {
        return self / 1000
    }
    var toPercent: Double {
        let min = 0.4
        let max = 2.0
        return Utils.inRangerPercent(num: (max - self) / (max - min)) * 100
    }
}
