//
//  Utils.swift
//  LinkageApp
//
//  Created by cuonghx on 5/24/19.
//  Copyright © 2019 Sun*. All rights reserved.
//

enum Utils {
    static func l2distance(_ feat1: [Double], _ feat2: [Double]) -> Double {
        return sqrt(zip(feat1, feat2).map { f1, f2 in pow(f2 - f1, 2) }.reduce(0, +))
    }
    
    static func getDistanceMin(f1: ModelFaceNet, f2: ModelFaceNet) -> Double {
        var distance = 2.0
        for i1 in f1.vector {
            for i2 in f2.vector {
                let d = l2distance(i1, i2)
                if d < distance {
                    distance = d
                }
            }
        }
        return distance
    }
    
    static func inRangerPercent(num: Double) -> Double {
        return num < 0 ? 0 : num > 1 ? 1 : num
    }
}
