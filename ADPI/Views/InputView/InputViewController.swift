//
//  InputViewController.swift
//  ADPI
//
//  Created by Matthew Sich on 3/20/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

struct InputStep {
    let title: String
    let description: String
    var number: String
    var convert: String?
    var isPercent: Bool
}

class InputViewController: UIViewController {
    
    @IBOutlet weak var pageControllerContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextBottomConstraint: NSLayoutConstraint!

    var pageController: UIPageViewController!
    var controllers: [InputItemView] = []
    var currentPage = 0
    var data: [InputStep] = []
    let newUser = User()

    private var hideNext: Bool = true {
        didSet {
            if hideNext {
                nextButton.isEnabled = false
                nextBottomConstraint.constant = -39
            } else {
                nextButton.isEnabled = true
                nextBottomConstraint.constant = 0
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        backButton.isHidden = true

        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        addChildViewController(pageController)
        pageController.willMove(toParentViewController: self)
        pageController.didMove(toParentViewController: self)
        pageControllerContainer.addSubview(pageController.view)

        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.view.leftAnchor.constraint(equalTo: pageControllerContainer.leftAnchor).isActive = true
        pageController.view.topAnchor.constraint(equalTo: pageControllerContainer.topAnchor).isActive = true
        pageController.view.rightAnchor.constraint(equalTo: pageControllerContainer.rightAnchor).isActive = true
        pageController.view.bottomAnchor.constraint(equalTo: pageControllerContainer.bottomAnchor).isActive = true

        pageController.setViewControllers([controllers[0]], direction: .forward, animated: false, completion: nil)

        updateNext(inputView: controllers[0])
    }

    @IBAction func goToNext(_ sender: UIButton) {
        guard currentPage < controllers.count - 1 else {
            finishOnboarding()
            return
        }
        currentPage += 1
        pageController.setViewControllers([controllers[currentPage]], direction: .forward, animated: true, completion: nil)
        updateNext(inputView: controllers[currentPage])
    }

    @IBAction func buttonSelected(_ sender: UIButton) {
        if let number = sender.titleLabel?.text {
            let currentVC = controllers[currentPage]
            currentVC.addNumber(number: number)
        }
    }

    @IBAction func clearSelected() {
        let currentVC = controllers[currentPage]
        currentVC.clear()
    }

    @IBAction func backSelected(_ sender: UIButton) {
        guard currentPage > 0 else { return }
        currentPage -= 1
        pageController.setViewControllers([controllers[currentPage]], direction: .reverse, animated: true, completion: nil)
        updateNext(inputView: controllers[currentPage])
    }

    private func updateNext(inputView: InputItemView) {
        if inputView.model.number == "0" {
            hideNext = true
        } else {
            hideNext = false
        }

        inputView.valueChangeHangler = { [weak self] value in
            guard let weakSelf = self else { return }
            if value == "0" {
                weakSelf.hideNext = true
            } else {
                weakSelf.hideNext = false
            }

            if weakSelf.currentPage == 3, let floatValue = Float(value), let floatTarget = Float(weakSelf.controllers[2].model.number) {
                inputView.convertedNumberLabel.text = ((floatValue / 100) * floatTarget).monify()
            }
        }

        backButton.isHidden = currentPage == 0
        nextButton.setTitle(currentPage == controllers.count - 1 ? "Finish" : "Next", for: .normal)
    }

    private func finishOnboarding() {
        newUser.saved = Float(controllers[0].model.number) ?? 0
        newUser.cashFlow = Float(controllers[1].model.number) ?? 0
        newUser.propertyPrice = Float(controllers[2].model.number) ?? 0
        newUser.downPayment = (Float(controllers[3].model.number) ?? 0) / 100 * (Float(controllers[2].model.number) ?? 0)
        newUser.interestRate = (Float(controllers[4].model.number) ?? 0) / 100
        newUser.averageRent = Float(controllers[5].model.number) ?? 0
        newUser.propertyExpenses = Float(controllers[6].model.number) ?? 0
        newUser.averageAppreciation = (Float(controllers[7].model.number) ?? 0) / 100
        newUser.save()
        navigationController?.popToRootViewController(animated: false)
    }

    private func setupViews() {

        data = [
            InputStep(title: "Amount Saved", description: "This is the total amount you currently have available to invest", number: "0", convert: nil, isPercent: false),
            InputStep(title: "Current Cashflow", description: "How much are you saving every month? Remember:\ncashflow = income - expenses", number: "0", convert: nil, isPercent: false),
            InputStep(title: "Average Property Price", description: "What is the average price of the properties you will be purchasing?", number: "0", convert: nil, isPercent: false),
            InputStep(title: "Down Payment", description: "What % down payment will you be putting down on these properties?", number: "0", convert: "0", isPercent: true),
            InputStep(title: "Estimated Interest Rate", description: "Estimate the interest rate based on your location and market trend", number: "0", convert: nil, isPercent: true),
            InputStep(title: "Average Rent", description: "How much are you expecting your rent will be?", number: "0", convert: nil, isPercent: false),
            InputStep(title: "Estimated Property Expenses", description: "Estimate the average expenses you will have for each of your properties.", number: "0", convert: nil, isPercent: false),
            InputStep(title: "Estimated Average Appreciation", description: "Your properties will apreciate some factor every year", number: "3", convert: nil, isPercent: true)
        ]
        var index = 0
        for pageData in data {
            let vc = InputItemView(nibName: "InputItemView", bundle: nil)
            vc.model = pageData
            vc.view.tag = index
            controllers.append(vc)
            index += 1
        }
    }
}
