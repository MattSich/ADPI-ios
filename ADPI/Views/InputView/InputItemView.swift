//
//  InputItemView.swift
//  ADPI
//
//  Created by Matthew Sich on 3/20/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

class InputItemView: UIViewController {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var convertedNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var suffixLabel: UILabel!
    
    public var model: InputStep!

    public var valueChangeHangler: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = model.title
        subtitleLabel.text = model.description
        numberLabel.text = model.number
        prefixLabel.text = !model.isPercent ? "$" : ""
        suffixLabel.text = model.isPercent ? "%" : ""

        if let convertText = model.convert {
            convertedNumberLabel.text = convertText
        } else {
            convertedNumberLabel.isHidden = true
        }
    }

    public func addNumber(number: String) {
        if number == "." && model.number.contains(".") {
            return
        }

        if model.number == "0" {
            if number == "." {
                model.number = "0\(number)"
            } else if number != "0" {
                model.number = number
            }
        } else {
            model.number += number
        }
        numberLabel.text = model.number

        valueChangeHangler?(model.number)
    }

    public func clear() {
        model.number = "0"
        numberLabel.text = model.number
        convertedNumberLabel.text = "$0"
    }
}
