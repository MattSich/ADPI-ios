//
//  CGFloatExtension.swift
//  ADPI
//
//  Created by Matthew Sich on 3/23/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGFloat {
    func rounded(toPlaces places:Int) -> CGFloat {
        let divisor = CGFloat(pow(10.0, Double(places)))
        return (self * divisor).rounded() / divisor
    }
}
