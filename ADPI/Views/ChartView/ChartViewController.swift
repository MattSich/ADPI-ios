//
//  ChartViewController.swift
//  ADPI
//
//  Created by Matthew Sich on 3/21/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit
import Charts
import SwiftyStoreKit
import JRMFloatingAnimation
import AudioToolbox.AudioServices
import Firebase

class ChartViewController: UIViewController {

    let kBubbleCellId = "bubbleCellId"
    let kButtonCellId = "buttonCellId"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var equityLabel: UILabel!
    @IBOutlet weak var equityValue: UILabel!
    @IBOutlet weak var equityButton: UIButton!
    @IBOutlet weak var equityView: UIView!

    @IBOutlet weak var cashflowLabel: UILabel!
    @IBOutlet weak var cashflowValue: UILabel!
    @IBOutlet weak var cashflowButton: UIButton!
    @IBOutlet weak var cashflowView: UIView!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet var indicatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var indicatorTrailingConstraint: NSLayoutConstraint!

    let model = ChartViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = 40
        tableView.contentInset.top = 30

        model.reloadData = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.tableView.reloadData()
        }

        model.monthChanged = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.addFloatingBubble()
        }

        updateMainLabelValues()
        setupChart()
        setChartData(type: model.currentChartType)
        dateLabel.text = model.currentDate()

        let bubbleCellNib = UINib(nibName: "BubbleCell", bundle: nil)
        tableView.register(bubbleCellNib, forCellReuseIdentifier: kBubbleCellId)

        let buttonCellNib = UINib(nibName: "ButtonCell", bundle: nil)
        tableView.register(buttonCellNib, forCellReuseIdentifier: kButtonCellId)

        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.iAPSharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { [weak self] result in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let receipt):
                let productId = Constants.oneMonthMembershipIAP
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)

                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    User.logout()
                    weakSelf.navigationController?.popToRootViewController(animated: true)
                case .notPurchased:
                    User.logout()
                    weakSelf.navigationController?.popToRootViewController(animated: true)
                }

            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.reloadInputs()
        setChartData(type: model.currentChartType)
        dateLabel.text = model.currentDate()
        tableView.reloadData()
    }

    @IBAction func cashflowSelected(_ sender: UIButton) {

        model.currentChartType = .cashflow
        setChartData(type: model.currentChartType)
        
        indicatorLeadingConstraint.isActive = false
        indicatorTrailingConstraint.isActive = false

        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.equityLabel.textColor = UIColor.white.withAlphaComponent(0.2)
            weakSelf.equityValue.textColor = .white
            weakSelf.cashflowLabel.textColor = .appRed
            weakSelf.cashflowValue.textColor = .appRed
            weakSelf.indicatorView.backgroundColor = .appRed
            weakSelf.view.layoutIfNeeded()
        }
    }

    @IBAction func equitySelected(_ sender: UIButton) {

        model.currentChartType = .equity
        setChartData(type: model.currentChartType)

        indicatorLeadingConstraint.isActive = true
        indicatorTrailingConstraint.isActive = true
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.cashflowLabel.textColor = UIColor.white.withAlphaComponent(0.2)
            weakSelf.cashflowValue.textColor = .white
            weakSelf.equityLabel.textColor = .appOrange
            weakSelf.equityValue.textColor = .appOrange
            weakSelf.indicatorView.backgroundColor = .appOrange
            weakSelf.view.layoutIfNeeded()
        }
    }

    @IBAction func settingsSelected(_ sender: Any) {
        let vc = SettingsViewCongroller(nibName: "SettingsViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupChart() {
        lineChart.delegate = self
        lineChart.drawGridBackgroundEnabled = false
        lineChart.drawBordersEnabled = false
        lineChart.chartDescription?.enabled = false
        lineChart.pinchZoomEnabled = false
        lineChart.dragEnabled = true
        lineChart.setScaleEnabled(false)
        lineChart.legend.enabled = false
        lineChart.xAxis.enabled = false
        lineChart.leftAxis.enabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.drawAxisLineEnabled = false
    }

    private func addFloatingBubble() {
        guard let floatingView = JRMFloatingAnimationView(starting: CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height)) else { return }
        floatingView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        floatingView.add(#imageLiteral(resourceName: "plusBubble"))
        floatingView.isUserInteractionEnabled = false
        floatingView.maxFloatObjectSize = 50
        floatingView.minFloatObjectSize = 30
        floatingView.floatingShape = JRMFloatingShape.triangleUp
        floatingView.fadeOut = true
        floatingView.varyAlpha = true
        floatingView.startingPointWidth = UIScreen.main.bounds.size.width/2
        floatingView.removeOnCompletion = true
        self.view.addSubview(floatingView)

        floatingView.animate()

        AudioServicesPlaySystemSound(1520) // Pop feedback
    }

    private func createDataSet(type: ChartType) -> [LineChartDataSet] {
        return [createSet(type: type, filled: true), createSet(type: type, filled: false)]
    }

    private func createSet(type: ChartType, filled: Bool) -> LineChartDataSet {
        var set1: LineChartDataSet!
        var chartColor: UIColor = .appOrange
        if type == .cashflow {
            chartColor = .appRed
            set1 = LineChartDataSet(values: model.cashflowData(limitToMonth: filled), label: "Cashflow")
        } else if type == .equity {
            set1 = LineChartDataSet(values: model.equityData(limitToMonth: filled), label: "Equity")
        }
        set1.axisDependency = .left
        set1.setColor(filled ? chartColor : UIColor.white.withAlphaComponent(0.2))
        set1.drawCirclesEnabled = false
        set1.lineWidth = 2
        set1.mode = .cubicBezier
        let gradientColors = [chartColor.withAlphaComponent(0).cgColor,
                              chartColor.withAlphaComponent(0.13).cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set1.fillAlpha = filled ? 1 : 0
        set1.fill = Fill(linearGradient: gradient, angle: 90)
        set1.drawFilledEnabled = filled
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        set1.fillFormatter = DefaultFillFormatter { _,_  -> CGFloat in
            return CGFloat(self.lineChart.leftAxis.axisMinimum)
        }

        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = false

        return set1
    }

    private func setChartData(type: ChartType) {
        let data = LineChartData(dataSets: createDataSet(type: type))
        data.setDrawValues(false)
        lineChart.data = data
    }

    private func updateMainLabelValues() {
        cashflowValue.text = model.currentMonthData().cashflow.monify()
        equityValue.text = model.currentMonthData().equity.monify()
    }
}

extension ChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        model.selectedMonth = entry.x
        updateMainLabelValues()
        setChartData(type: model.currentChartType)
        dateLabel.text = model.currentDate()
    }
}

extension ChartViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? model.tableData().count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: kBubbleCellId, for: indexPath) as? BubbleCell else {
                fatalError()
            }
            cell.setup(top: model.tableData()[indexPath.row].top, bottom: model.tableData()[indexPath.row].bottom)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: kButtonCellId, for: indexPath) as? ButtonCell else {
                fatalError()
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0, let url = URL(string: "https://www.activedutypassiveincome.com/p/military-real-estate-investing-academy") {
            Analytics.logEvent("sign_up_for_academy_selected", parameters: nil)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
