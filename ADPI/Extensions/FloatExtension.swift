//
//  FloatExtension.swift
//  ADPI
//
//  Created by Matthew Sich on 3/23/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import Foundation

extension Float {
    func monify() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }

    func percentify() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }

    func prettyPrint() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
