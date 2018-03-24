//
//  ProjectorTest.swift
//  ADPITests
//
//  Created by Matthew Sich on 3/21/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import XCTest
@testable import ADPI

class ProjectorTest: XCTestCase {

    var user: User!

    override func setUp() {
        super.setUp()

        user = User()
        user.saved = 20000
        user.cashFlow = 250
        user.propertyPrice = 200000
        user.downPayment = 20000
        user.interestRate = 0.03
        user.averageRent = 1200
        user.propertyExpenses = 400
        user.averageAppreciation = 0.03
        user.start = "01/18/2018".toDate() ?? Date()

    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let moments = Projector.all(user)
        print("month    |properties     |equity     |cashflow       |Money In Bank")
        for (month, moment) in moments.enumerated() {
            print("\(month + 1)     |\(moment.numberOfProperties)        |\(moment.equity.monify())      |\(moment.cashflow.monify())     |\(moment.moneyInBank.monify())     ")
        }
    }

    func testAmortization() {
        let amortizationPayment = Projector.amortCalc(loanAmount: 200000, interestRate: 0.03, numberOfPayments: 30*12)
        XCTAssertEqual(amortizationPayment.rounded(toPlaces: 2), 843.21)
    }

}
