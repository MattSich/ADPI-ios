//
//  InfoModal.swift
//  ADPI
//
//  Created by Matthew Sich on 5/13/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

class InfoModal: UIViewController {

    @IBOutlet private weak var verticalCenterConstraint: NSLayoutConstraint!

    @IBOutlet private weak var shroud: UIButton!
    @IBOutlet private weak var modalView: UIView!

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    public var modalTitle: String = ""
    public var modalDescription: String = ""

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

        titleLabel.text = modalTitle
        descriptionLabel.text = modalDescription
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
