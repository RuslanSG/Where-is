//
//  SettingsTableViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 13.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
    
    func colorModeStateChanged(to state: Bool)

}

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var colorSwitcher: UISwitch!
    @IBOutlet weak var changeColorSwitcher: UISwitch!
    @IBOutlet weak var changeNumbersSwitcher: UISwitch!
    
    var delegate: SettingsTableViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        colorSwitcher.setOn(Game.shared.colorMode, animated: false)
        changeColorSwitcher.setOn(Game.shared.shuffleColorsMode, animated: false)
        changeNumbersSwitcher.setOn(Game.shared.shuffleNumbersMode, animated: false)
    }
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func colorSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.colorMode = sender.isOn
        delegate?.colorModeStateChanged(to: sender.isOn)
    }
    
    @IBAction func changeColorSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.shuffleColorsMode = sender.isOn
    }
    
    @IBAction func changeNumbersSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.shuffleNumbersMode = sender.isOn
    }

}
