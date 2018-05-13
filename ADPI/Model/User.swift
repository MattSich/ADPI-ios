//
//  User.swift
//  ADPI
//
//  Created by Matthew Sich on 3/23/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import Foundation
import CoreGraphics

class User: Codable {

    private static let kUserKey = "com.mattsich.ADPI.user"

    var saved: Float
    var cashFlow: Float
    var propertyPrice: Float
    var downPayment: Float
    var interestRate: Float
    var averageRent: Float
    var propertyExpenses: Float
    var averageAppreciation: Float
    var start: Date
    var confirmed: Bool

    init() {
        saved = 0
        cashFlow = 0
        propertyPrice = 0
        downPayment = 0
        interestRate = 0
        averageRent = 0
        propertyExpenses = 0
        averageAppreciation = 0.03
        start = Date()
        confirmed = false

        reload()
    }

    public func reload() {
        if let user = getSaved(){
            saved = user.saved
            cashFlow = user.cashFlow
            propertyPrice = user.propertyPrice
            downPayment = user.downPayment
            interestRate = user.interestRate
            averageRent = user.averageRent
            propertyExpenses = user.propertyExpenses
            averageAppreciation = user.averageAppreciation
            start = user.start
            confirmed = user.confirmed
        }
    }

    public func getSingleMorgage() -> Float {
        return Float(Projector.amortCalc(loanAmount: CGFloat(propertyPrice - downPayment), interestRate: CGFloat(interestRate), numberOfPayments: Projector.monthsPerYear*Projector.numberOfYears))
    }

    private func getSaved() -> User? {
        do {
            guard let data = UserDefaults.standard.object(forKey: User.kUserKey) as? Data else { return nil }
            let decoded = try JSONDecoder().decode(User.self, from: data)
            return decoded
        } catch {
            return nil
        }
    }

    public func save() {
        do {
            let encoded = try JSONEncoder().encode(self)
            UserDefaults.standard.set(encoded, forKey: User.kUserKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("failed to save user")
        }
    }

    public static func logout() {
        UserDefaults.standard.removeObject(forKey: kUserKey)
        UserDefaults.standard.synchronize()
    }

    public static func exists() -> Bool {
        return UserDefaults.standard.object(forKey: kUserKey) != nil
    }

}
