//
//  SettingsViewController.swift
//  ADPI
//
//  Created by Matthew Sich on 3/24/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

struct MainSettingRow {
    let name: String
    let action: ((UIViewController) -> Void)?
}

class SettingsViewCongroller: UIViewController {

    let kCell = "settingsCell"
    
    @IBOutlet weak var tableView: UITableView!

    let rows: [MainSettingRow] = [
        MainSettingRow(name: "Manage Subscription", action: { context in
            let alert = UIAlertController(title: "Manage Subscription", message: "This will eventually give you info about managing your subscription", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            context.present(alert, animated: true, completion: nil)
        }),
        MainSettingRow(name: "Change calculation data", action: { context in
            let vc = DataSettingsViewController(nibName: "SettingsViewController", bundle: nil)
            context.navigationController?.pushViewController(vc, animated: true)
        }),
        MainSettingRow(name: "Log Out", action: { context in
            User.logout()
            context.navigationController?.popToRootViewController(animated: true)
        })
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

