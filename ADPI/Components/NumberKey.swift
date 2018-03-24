//
//  NumberKey.swift
//  ADPI
//
//  Created by Matthew Sich on 3/20/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

@IBDesignable
class NumberKey: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        setTitleColor(.white, for: .normal)
        backgroundColor = .clear
    }

    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                superview?.bringSubview(toFront: self)
                backgroundColor = UIColor(red:0.25, green:0.27, blue:0.34, alpha:1.00)
                layer.shadowRadius = 13
                layer.shadowOffset = CGSize(width: 0, height: 8)
                layer.shadowOpacity = 0.24
                layer.shadowColor = UIColor.black.cgColor
            }
            else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: { [unowned self] in
                    self.backgroundColor = UIColor.clear
                }, completion: nil)
                let animation = CABasicAnimation(keyPath: "shadowOpacity")
                animation.fromValue = layer.shadowOpacity
                animation.toValue = 0.0
                animation.duration = 0.3
                layer.add(animation, forKey: animation.keyPath)
                layer.shadowOpacity = 0.0
            }
            super.isHighlighted = newValue
        }
    }
}
