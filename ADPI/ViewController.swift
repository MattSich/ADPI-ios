//
//  ViewController.swift
//  ADPI
//
//  Created by Matthew Sich on 3/20/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var legalTextView: UITextView!
    @IBOutlet weak var restorePurchaseButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        legalTextView.attributedText = composeLegalText()
        legalTextView.tintColor = UIColor.appRed

        restorePurchaseButton.layer.borderColor = UIColor.appRed.cgColor
        restorePurchaseButton.layer.borderWidth = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let vc = InputViewController(nibName: "InputViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: false)
        if User.exists() {
            let vc = ChartViewController(nibName: "ChartViewController", bundle: nil)
            navigationController?.pushViewController(vc, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func restorePurchaseSelected() {
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
                    let vc = InputViewController(nibName: "InputViewController", bundle: nil)
                    weakSelf.navigationController?.pushViewController(vc, animated: false)
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }

            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    @IBAction func subscribeSelected(_ sender: UIButton) {

        Analytics.logEvent("subscribe_selected", parameters: [:])

        let modal = SubscribeModal(nibName: "SubscribeModal", bundle: nil)
        modal.subscribeSelected = {
            SwiftyStoreKit.purchaseProduct(Constants.oneMonthMembershipIAP, quantity: 1, atomically: true) { [weak self] result in
                guard let weakSelf = self else { return }
                switch result {
                case .success(let purchase):
                    print("Purchase Success: \(purchase.productId)")
                    let vc = InputViewController(nibName: "InputViewController", bundle: nil)
                    weakSelf.navigationController?.pushViewController(vc, animated: false)
                case .error(let error):
                    switch error.code {
                    case .unknown: weakSelf.showPurchaseError(message: "Unknown error. Please contact support")
                    case .clientInvalid: weakSelf.showPurchaseError(message: "Not allowed to make the payment")
                    case .paymentCancelled:
                        Analytics.logEvent("subscribe_failed", parameters: [
                            "reason": "canceled" as NSObject,
                            ])
                        break
                    case .paymentInvalid: weakSelf.showPurchaseError(message: "The purchase identifier was invalid")
                    case .paymentNotAllowed: weakSelf.showPurchaseError(message: "Your device is not allowed to make the payment")
                    case .storeProductNotAvailable: weakSelf.showPurchaseError(message: "This product is not available in your region")
                    case .cloudServicePermissionDenied: weakSelf.showPurchaseError(message: "Access to cloud service information is not allowed")
                    case .cloudServiceNetworkConnectionFailed: weakSelf.showPurchaseError(message: "Could not connect to the network")
                    case .cloudServiceRevoked: weakSelf.showPurchaseError(message: "You have pevisously revoked permission to use this cloud service")
                    }
                }
            }
        }
        modal.modalPresentationStyle = .overCurrentContext
        present(modal, animated: false, completion: nil)

    }

    func showPurchaseError(message: String) {
        Analytics.logEvent("subscribe_failed", parameters: [
            "reason": message as NSObject,
            ])

        let alert = UIAlertController(title: "Failed to purchase", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func composeLegalText() -> NSAttributedString {
        let str = NSMutableAttributedString(string: "")

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center

        let regularTextAttrs: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont(name: "Montserrat-SemiBold", size: 10) as Any,
            NSAttributedStringKey.foregroundColor: UIColor.gray,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]

        let privacyLink: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont(name: "Montserrat-SemiBold", size: 10) as Any,
            NSAttributedStringKey.link: Constants.privacyPolicyURL,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]

        let termsLink: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont(name: "Montserrat-SemiBold", size: 10) as Any,
            NSAttributedStringKey.link: Constants.termsOfServiceURL,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]

        str.append(NSAttributedString(string: "By subscribing up, you agree to our ", attributes: regularTextAttrs))
        str.append(NSAttributedString(string: "Privacy Policy", attributes: privacyLink))
        str.append(NSAttributedString(string: " and ", attributes: regularTextAttrs))
        str.append(NSAttributedString(string: "Terms of Service", attributes: termsLink))
        str.append(NSAttributedString(string: ".", attributes: regularTextAttrs))

        return str
    }
}

