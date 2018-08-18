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
    @IBOutlet weak var shuffleColorSwitcher: UISwitch!
    @IBOutlet weak var shuffleNumbersSwitcher: UISwitch!
    
    var delegate: SettingsTableViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        colorSwitcher.setOn(Game.shared.colorMode, animated: false)
        shuffleColorSwitcher.setOn(Game.shared.shuffleColorsMode, animated: false)
        shuffleNumbersSwitcher.setOn(Game.shared.shuffleNumbersMode, animated: false)
        if !colorSwitcher.isOn {
            shuffleColorSwitcher.isEnabled = false
            shuffleColorSwitcher.setOn(false, animated: false)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func colorSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.colorMode = sender.isOn
        Game.shared.shuffleColorsMode = false
        delegate?.colorModeStateChanged(to: sender.isOn)
        if !sender.isOn && shuffleColorSwitcher.isOn {
            shuffleColorSwitcher.setOn(false, animated: true)
        }
        shuffleColorSwitcher.isEnabled = sender.isOn
    }
    
    @IBAction func shuffleColorSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.shuffleColorsMode = sender.isOn
    }
    
    @IBAction func shuffleNumbersSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.shuffleNumbersMode = sender.isOn
    }

}
