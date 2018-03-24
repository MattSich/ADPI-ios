//
//  ViewController.swift
//  ADPI
//
//  Created by Matthew Sich on 3/20/18.
//  Copyright © 2018 Matthew Sich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if User.exists() {
            let vc = ChartViewController(nibName: "ChartViewController", bundle: nil)
            navigationController?.pushViewController(vc, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func subscribeSelected(_ sender: UIButton) {
        let vc = InputViewController(nibName: "InputViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: false)
    }

}

