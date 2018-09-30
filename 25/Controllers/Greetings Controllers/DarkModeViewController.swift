//
//  DarkModeViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/29/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol DarkModeViewControllerDelegate {
    func automaticDarkModeStateChanged(to state: Bool)
}

class DarkModeViewController: UIViewController {
    
    var delegate: DarkModeViewControllerDelegate?
    
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var sunsetTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // MARK: - Actions
    
    @IBAction func automaticDarkModeSwitcherValueChanged(_ sender: UISwitch) {
        
    }

}
