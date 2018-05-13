//
//  SettingsViewController.swift
//  ADPI
//
//  Created by Matthew Sich on 3/24/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit
import Firebase

struct MainSettingRow {
    let name: String
    let action: ((UIViewController) -> Void)?
}

class SettingsViewCongroller: UIViewController {

    let kCell = "settingsCell"
    
    @IBOutlet weak var tableView: UITableView!

    let rows: [MainSettingRow] = [
        MainSettingRow(name: "Manage Subscription", action: { context in
            Analytics.logEvent("manage_subscription_selected", parameters: [:])
            SettingsViewCongroller.manageSelected(context: context)
        }),
        MainSettingRow(name: "Change calculation data", action: { context in
            let vc = DataSettingsViewController(nibName: "SettingsViewController", bundle: nil)
            context.navigationController?.pushViewController(vc, animated: true)
        }),
        MainSettingRow(name: "Terms of Service", action: { context in
            guard let url = URL(string: Constants.termsOfServiceURL) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }),
        MainSettingRow(name: "Privacy Policy", action: { context in
            guard let url = URL(string: Constants.privacyPolicyURL) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }),
//        MainSettingRow(name: "Clear Data", action: { context in
//            User.logout()
//            context.navigationController?.popToRootViewController(animated: true)
//        })
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset.top = 30
        tableView.contentInset.bottom = 30

        let nib = UINib(nibName: "SettingsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: kCell)
    }

    @IBAction func backSelected() {
        navigationController?.popViewController(animated: true)
    }

    static func manageSelected(context: UIViewController) {
        let subscriptionModal = UIAlertController(title: "ADPI Subscription", message: "Your subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current 1 month period. Your account will be charged $3.99 USD for renewal within 24-hours prior to the end of the current 1 month period. You can manage your subscription by selecting the \"manage\" button. By subscribing you have agreed to our terms of service and privacy policy.", preferredStyle: .alert)
        subscriptionModal.addAction(UIAlertAction(title: "manage", style: .default, handler: { (_) in
            guard let url = URL(string: Constants.manageSubscriptionURL) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        subscriptionModal.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        context.present(subscriptionModal, animated: true, completion: nil)
    }
}

extension SettingsViewCongroller: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kCell, for: indexPath) as? SettingsCell else {
            fatalError("Failed to dequeue cell")
        }
        cell.mainLabel.text = rows[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rows[indexPath.row].action?(self)
    }
}

