//
//  WelcomeViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/29/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol WelcomeViewControllerDelegate {
    func doneButtonPressed()
}

class WelcomeViewController: UIViewController {

    var delegate: WelcomeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        delegate?.doneButtonPressed()
    }

}
