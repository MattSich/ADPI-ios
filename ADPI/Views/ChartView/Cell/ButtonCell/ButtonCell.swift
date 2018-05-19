//
//  ButtonCell.swift
//  ADPI
//
//  Created by Matthew Sich on 5/19/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        bubbleView.layer.cornerRadius = 3
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 10)
        bubbleView.layer.shadowRadius = 5
        bubbleView.layer.shadowOpacity = 0.1

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}
