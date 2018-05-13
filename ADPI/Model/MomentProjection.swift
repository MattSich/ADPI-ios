//
//  User.swift
//  ADPI
//
//  Created by Matthew Sich on 3/21/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import Foundation

struct MomentProjection: Codable {
    let month: Int
    let equity: Float
    let cashflow: Float
    let totalExpenses: Float
    let mortgagePayment: Float
    let principlePayment: Float
    let interestPayment: Float
    let numberOfProperties: Int
    let moneyInBank: Float
    let totalInterestPaid: Float
    let equityGained: Float
}
