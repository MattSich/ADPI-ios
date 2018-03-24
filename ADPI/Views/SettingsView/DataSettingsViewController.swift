//
//  DataSettingsView.swift
//  ADPI
//
//  Created by Matthew Sich on 3/24/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

struct DataSettingsRow {
    let name: String
    let value: String
    let action: ((UIViewController) -> Void)?
}

class DataSettingsViewController: SettingsViewCongroller {

    let kDataCell = "dataSettingsRow"

    var dataRows: [DataSettingsRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "BubbleCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: kDataCell)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
    }

    private func reloadData() {
        dataRows = [
            DataSettingsRow(name: "Starting Savings", value: User().saved.monify(), action: nil),
            DataSettingsRow(name: "Starting Cashflow", value: User().cashFlow.monify(), action: nil),
            DataSettingsRow(name: "Average Property Price", value: User().propertyPrice.monify(), action: nil),
            DataSettingsRow(name: "Down Payment", value: User().downPayment.monify(), action: nil),
            DataSettingsRow(name: "Estimated Interest Rate", value: User().interestRate.percentify(), action: nil),
            DataSettingsRow(name: "Average Rent", value: User().averageRent.monify(), action: nil),
            DataSettingsRow(name: "Estimated Property Expenses", value: User().propertyExpenses.monify(), action: nil),
            DataSettingsRow(name: "Estimated Average Appreciation", value: User().averageAppreciation.percentify(), action: nil),
            DataSettingsRow(name: "Start Date", value: User().start.printNice(), action: nil)
        ]
        tableView.reloadData()
    }
}

extension DataSettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataRows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kDataCell, for: indexPath) as? BubbleCell else {
            fatalError("Failed to dequeue cell")
        }
        cell.topLabel.text = dataRows[indexPath.row].name
        cell.bottomLabel.text = dataRows[indexPath.row].value
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == dataRows.count - 1 {
            let modal = ChangeDateModal(nibName: "ChangeDateModal", bundle: nil)
            modal.date = User().start
            modal.dateDidChange = { [weak self] newDate in
                guard let weakSelf = self else { return }
                let user = User()
                user.start = newDate
                user.save()
                weakSelf.reloadData()
            }
            modal.modalPresentationStyle = .overCurrentContext
            present(modal, animated: false, completion: nil)
            return
        }
        let vc = InputViewController(nibName: "InputViewController", bundle: nil)
        vc.onlyOneInput = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
}
