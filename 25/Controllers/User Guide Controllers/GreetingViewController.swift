//
//  GreetingViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 2/3/19.
//  Copyright © 2019 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol GreetingViewControllerDelegate {
    func skipButtonPressed()
}

class GreetingViewController: UIViewController {
    
    var delegate: GreetingViewControllerDelegate?
    
    // MARK: - Actions
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: UserDefaults.Key.NotFirstLaunch)
        delegate?.skipButtonPressed()
    }
}
