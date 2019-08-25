//
//  WelcomeViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 8/25/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol WelcomeViewControllerDelegate: class {
    
    func nextButtonPressed(_ viewController: WelcomeViewController)
    func skipButtonPressed(_ viewController: WelcomeViewController)
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    weak var delegate: WelcomeViewControllerDelegate?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAttributedTextToWelcomeLabel()
    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        delegate?.nextButtonPressed(self)
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        delegate?.skipButtonPressed(self)
    }
    
    // MARK: - Helper Methods
    
    private func setAttributedTextToWelcomeLabel() {
        let stringToColor = "Where is?!"
        let colorfulTextRange = (welcomeLabel.text! as NSString).range(of: stringToColor)
        let attributedString = NSMutableAttributedString(string: welcomeLabel.text!)
        attributedString.addAttribute(.foregroundColor, value: UIColor.cellTurquoise, range: colorfulTextRange)
        welcomeLabel.attributedText = attributedString
    }
    

}
