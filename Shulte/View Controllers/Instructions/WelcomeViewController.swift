//
//  WelcomeViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 8/25/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol WelcomeViewControllerDelegate: AnyObject {
    
    func welcomeViewController(_ welcomeViewController: WelcomeViewController, nextButtonDidPress nextButton: UIButton)
    func welcomeViewController(_ welcomeViewController: WelcomeViewController, skipButtonDidPress nextButton: UIButton)
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    weak var delegate: WelcomeViewControllerDelegate?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            labels.forEach { $0.textColor = .label }
            nextButton.tintColor = .systemBlue
            skipButton.tintColor = .systemBlue
        }
        
        setAttributedTextToWelcomeLabel()
    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        delegate?.welcomeViewController(self, nextButtonDidPress: sender)
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        delegate?.welcomeViewController(self, skipButtonDidPress: sender)
    }
    
    // MARK: - Helper Methods
    
    private func setAttributedTextToWelcomeLabel() {
        let `where` = "Where"
        let `is` = "is"
        
        let whereRange = (welcomeLabel.text! as NSString).range(of: `where`)
        let isRange = (welcomeLabel.text! as NSString).range(of: `is`)
        
        let attributedString = NSMutableAttributedString(string: welcomeLabel.text!)
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.systemBlue,
            range: whereRange
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.systemYellow,
            range: isRange
        )
        welcomeLabel.attributedText = attributedString
    }
    

}
