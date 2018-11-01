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

    @IBOutlet var labels: [UILabel]!
    
    var delegate: WelcomeViewControllerDelegate?
    var appearance: Appearance!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupColors()
    }

    // MARK: - Actions
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        delegate?.doneButtonPressed()
    }    
    
    // MARK: - Helping methods
    
    private func setupColors() {
        self.labels.forEach { $0.textColor = self.appearance.textColor }
        self.view.backgroundColor = self.appearance.darkMode ? self.appearance.tableViewBackgroundColor : .white
    }

}
