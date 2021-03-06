//
//  ChartViewModel.swift
//  ADPI
//
//  Created by Matthew Sich on 3/24/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import Foundation
import Charts

class ChartViewModel {
    private var moments: [MomentProjection] = []
    var user: User!
    var lastMonth = 0
    var currentChartType: ChartType = .equity
    public var selectedMonth: Double = 0 {
        didSet {
            if lastMonth < currentMonthData().numberOfProperties {
                for _ in lastMonth ..< currentMonthData().numberOfProperties {
                    monthChanged?()
                }
            }
            lastMonth = currentMonthData().numberOfProperties
            reloadData?()
        }
    }

    public var monthChanged: (() -> Void)?
    public var reloadData: (() -> Void)?
    init() {
        user = User()
        reloadInputs()
    }

    public func reloadInputs() {
        user.reload()
        moments = Projector.all(user)
    }

    func currentMonthData() -> MomentProjection {
        guard Int(selectedMonth) < moments.count else { return moments[moments.count-1] }
        return moments[Int(selectedMonth)]
    }

    func currentDate() -> String {
        let cal = NSCalendar.current
        let date = cal.date(byAdding: .month, value: Int(selectedMonth), to: user.start)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date ?? Date())
    }

    func tableData() -> [RowItem] {
        let data = currentMonthData()
        return [
            RowItem(top: "Number of properties", bottom: String(data.numberOfProperties)),
            RowItem(top: "Savings", bottom: data.moneyInBank.monify()),
            RowItem(top: "Total costs this month (mortgage + expenses)", bottom: data.totalExpenses.monify()),
            RowItem(top: "Interest being paid this month", bottom: data.interestPayment.monify()),
            RowItem(top: "Equity gained this month", bottom: data.equityGained.monify()),
            RowItem(top: "Total interest paid to date", bottom: data.totalInterestPaid.monify())
        ]
    }

    func equityData(limitToMonth: Bool) -> [ChartDataEntry] {
        let data = moments.map { (moment) -> ChartDataEntry in
            return ChartDataEntry(x: Double(moment.month), y: Double(moment.equity))
        }
        return limitToMonth ? data.filter { $0.x < Double(selectedMonth) } : data
    }
    func cashflowData(limitToMonth: Bool) -> [ChartDataEntry] {
        let data = moments.map { (moment) -> ChartDataEntry in
            return ChartDataEntry(x: Double(moment.month), y: Double(moment.cashflow))
        }
        return limitToMonth ? data.filter { $0.x < Double(selectedMonth) } : data
    }
}

struct RowItem {
    let top: String
    let bottom: String
}

enum ChartType {
    case equity, cashflow
}
