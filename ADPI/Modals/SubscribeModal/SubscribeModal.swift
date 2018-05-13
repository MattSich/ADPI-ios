//
//  SubscribeModal.swift
//  ADPI
//
//  Created by Matthew Sich on 5/7/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

class SubscribeModal: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var shroud: UIButton!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var verticalCenterConstraint: NSLayoutConstraint!

    public var subscribeSelected: (() -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        shroud.alpha = 0
        modalView.alpha = 0
        verticalCenterConstraint.constant = -100
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        verticalCenterConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.shroud.alpha = 1
            weakSelf.modalView.alpha = 1
            weakSelf.view.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func doneSelected(_ sender: Any) {
        subscribeSelected?()
        cancel(sender)
    }

    @IBAction func cancel(_ sender: Any) {
        verticalCenterConstraint.constant = 500
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.shroud.alpha = 0
            weakSelf.modalView.alpha = 0
            weakSelf.view.layoutIfNeeded()
        }) { [weak self] (finished) in
            guard let weakSelf = self else { return }
            if finished {
                weakSelf.dismiss(animated: false, completion: nil)
            }
        }
    }
    
}
