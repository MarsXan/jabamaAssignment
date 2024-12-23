//
//  Double+Ext.swift
//  Fitness
//
//  Created by mohsen mokhtari on 9/10/23.
//

import Foundation
extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
    
    func round(to places: Int) -> Double {
            let divisor = pow(10.0, Double(places))
            return Darwin.round(self * divisor) / divisor
        }
    
    var toRadiant: Double {
        return self * .pi / 180.0
    }
}
