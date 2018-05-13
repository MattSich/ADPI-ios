//
//  ConfirmCashflowViewController.swift
//  ADPI
//
//  Created by Matthew Sich on 5/13/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit
import Firebase

class ConfirmCashflowViewController: UIViewController {
    @IBOutlet weak var finishButton: UIButton!
    
    @IBOutlet weak var cashflowLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var mortgageLabel: UILabel!
    @IBOutlet weak var rentPriceLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var expensesInfoButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        warningLabel.isHidden = true

        let user = User()
        rentPriceLabel.text = user.averageRent.monify()
        mortgageLabel.text = (user.getSingleMorgage() * -1).monify()
        expensesLabel.text = (user.propertyExpenses * -1).monify()
        let cashflow = user.averageRent - user.propertyExpenses - user.getSingleMorgage()
        cashflowLabel.text = cashflow.monify()

        if cashflow < 0 {
            finishButton.alpha = 0.3
            finishButton.isEnabled = false
            warningLabel.isHidden = false
            cashflowLabel.textColor = UIColor.appRed

            Analytics.logEvent("cashflow_overview", parameters: [
                "negative": "\(cashflow < 0 ? "true" : "false")" as NSObject,
                "cashflow": "\(cashflow)" as NSObject
                ])
        }

        updateUI()
    }

    func updateUI() {
        cardView.layer.cornerRadius = 3
        expensesInfoButton.layer.cornerRadius = expensesInfoButton.frame.size.width/2
    }
    
    @IBAction func backSelected() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func expensesInfoSelected() {
        let modal = InfoModal(nibName: "InfoModal", bundle: nil)
        modal.modalTitle = "Expenses"
        modal.modalDescription = "This includes taxes, insurance, property management, maintenance, CapEx, and Vacancies."
        modal.modalPresentationStyle = .overCurrentContext
        present(modal, animated: false, completion: nil)
    }

    @IBAction func finishButtonSelected() {
        let user = User()

        user.confirmed = true
        user.save()

        Analytics.logEvent("onboarding_finished", parameters: [
            "saved": "\(user.saved)" as NSObject,
            "cashFlow": "\(user.cashFlow)" as NSObject,
            "propertyPrice": "\(user.propertyPrice)" as NSObject,
            "downPayment": "\(user.downPayment)" as NSObject,
            "interestRate": "\(user.interestRate)" as NSObject,
            "averageRent": "\(user.averageRent)" as NSObject,
            "propertyExpenses": "\(user.propertyExpenses)" as NSObject,
            "averageAppreciation": "\(user.averageAppreciation)" as NSObject,
            ])

        navigationController?.popToRootViewController(animated: false)
    }
}
