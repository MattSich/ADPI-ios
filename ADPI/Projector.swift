//
//  Projector.swift
//  ADPI
//
//  Created by Matthew Sich on 3/21/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import Foundation
import CoreGraphics

struct MortgagePaymentBreakdown {
    let interest: CGFloat
    let principle: CGFloat
    let month: Int
}

class Projector {

    static let numberOfYears: Int = 30
    static let monthsPerYear: Int = 12

    static func all(_ user: User) -> [MomentProjection] {

        var moments: [MomentProjection] = []

        var currentSavings = user.saved
        var totalExpenses: Float = 0
        var cashflow: Float = user.cashFlow
        var properties: [Property] = []

        var principalPayments: CGFloat = 0
        var interestPayments: CGFloat = 0

        let monthlyPayment = amortCalc(loanAmount: CGFloat(user.propertyPrice - user.downPayment), interestRate: CGFloat(user.interestRate), numberOfPayments: monthsPerYear*numberOfYears)
        let loanSchedule = paymentBreakdown(totalMortgage: monthlyPayment, loanAmount: CGFloat(user.propertyPrice - user.downPayment), rate: CGFloat(user.interestRate), numberOfPeriods: monthsPerYear*numberOfYears)

        for month in 1...(monthsPerYear*numberOfYears) {

            var principalPayment: CGFloat = 0
            var interestPayment: CGFloat = 0
            
            totalExpenses = (user.propertyExpenses * Float(properties.count)) + (Float(monthlyPayment) * Float(properties.count))
            cashflow = user.cashFlow + (user.averageRent * Float(properties.count)) - totalExpenses
            currentSavings += cashflow

            // check if ready to buy
            var purchaseLimit = 10
            while currentSavings >= user.downPayment && purchaseLimit > 0 {
                // Buy new house
                currentSavings -= user.downPayment
                properties.append(Property(monthBought: month, value: user.propertyPrice, interestPaid: 0, principlePaid: 0))
                purchaseLimit -= 1;
            }

            var propertyEquity: Float = 0
            var properyValues: Float = 0
            // appreciate properties
            for (index, property) in properties.enumerated() {
                let paymentBreakdown = loanSchedule[month - 1]
                let principle = paymentBreakdown.principle
                let interest = paymentBreakdown.interest

                principalPayments += principle
                interestPayments += interest

                principalPayment += principle
                interestPayment += interest

                properties[index].principlePaid += Float(principle)
                properties[index].interestPaid += Float(interest)
                properties[index].value = property.value * (1 + (user.averageAppreciation / 12))
                properyValues += properties[index].value
                propertyEquity += properties[index].principlePaid + Float(user.downPayment)
            }

            moments.append(MomentProjection(
                month: month,
                equity: propertyEquity,
                cashflow: cashflow,
                totalExpenses: totalExpenses,
                mortgagePayment: Float(monthlyPayment),
                principlePayment: Float(principalPayment),
                interestPayment: Float(interestPayment),
                numberOfProperties: properties.count,
                moneyInBank: currentSavings,
                totalInterestPaid: Float(interestPayments),
                equityGained: Float(principalPayment)
                )
            )
        }

        return moments
    }

    private struct Property {
        let monthBought: Int
        var value: Float
        var interestPaid: Float = 0
        var principlePaid: Float = 0
    }

    internal static func amortCalc(loanAmount: CGFloat, interestRate: CGFloat, numberOfPayments: Int) -> CGFloat {
        return CGFloat(pmt(rate: Double(interestRate/12), nper: Double(numberOfPayments), pv: Double(loanAmount))) * -1
    }

    private static func pmt(rate : Double, nper : Double, pv : Double, fv : Double = 0, type : Double = 0) -> Double {
        return ((-pv * pvif(rate: rate, nper: nper) - fv) / ((1.0 + rate * type) * fvifa(rate: rate, nper: nper)))
    }

    private static func pow1pm1(x : Double, y : Double) -> Double {
        return (x <= -1) ? pow((1 + x), y) - 1 : exp(y * log(1.0 + x)) - 1
    }

    private static func pow1p(x : Double, y : Double) -> Double {
        return (abs(x) > 0.5) ? pow((1 + x), y) : exp(y * log(1.0 + x))
    }

    private static func pvif(rate : Double, nper : Double) -> Double {
        return pow1p(x: rate, y: nper)
    }

    private static func fvifa(rate : Double, nper : Double) -> Double {
        return (rate == 0) ? nper : pow1pm1(x: rate, y: nper) / rate
    }

    public static func paymentBreakdown(totalMortgage: CGFloat, loanAmount: CGFloat, rate: CGFloat, numberOfPeriods: Int) -> [MortgagePaymentBreakdown] {
        let periodInt = (rate / 12)
        var amount: CGFloat = loanAmount
        var result: [MortgagePaymentBreakdown] = []
        for i in 1...numberOfPeriods {
            if amount < 0 {
                break;
            }
            let interestPayment = amount * CGFloat(periodInt)
            let principlePayment = totalMortgage - interestPayment
            amount = amount - principlePayment
            result.append(MortgagePaymentBreakdown(interest: interestPayment, principle: principlePayment, month: i))
        }
        return result
    }
}
