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
    func levelChanged(to level: Int)
    func maxNumberChanged(to maxNumber: Int)

}

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var colorSwitcher: UISwitch!
    @IBOutlet weak var shuffleColorSwitcher: UISwitch!
    @IBOutlet weak var shuffleNumbersSwitcher: UISwitch!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var maxNumberLabel: UILabel!
    
    @IBOutlet weak var levelStepper: UIStepper!
    @IBOutlet weak var maxNumberStepper: UIStepper!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var userInterfaceColor: UIColor!
    
    var delegate: SettingsTableViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        colorSwitcher.setOn(Game.shared.colorMode, animated: false)
        colorSwitcher.onTintColor = userInterfaceColor
        
        shuffleColorSwitcher.setOn(Game.shared.shuffleColorsMode, animated: false)
        shuffleColorSwitcher.onTintColor = userInterfaceColor
        
        shuffleNumbersSwitcher.setOn(Game.shared.shuffleNumbersMode, animated: false)
        shuffleNumbersSwitcher.onTintColor = userInterfaceColor
        
        doneButton.tintColor = userInterfaceColor
        
        if !colorSwitcher.isOn {
            shuffleColorSwitcher.isEnabled = false
            shuffleColorSwitcher.setOn(false, animated: false)
        }
        
        levelLabel.text = String(Game.shared.level)
        maxNumberLabel.text = String(Game.shared.maxNumber)
        
        levelStepper.maximumValue = Double(Game.shared.maxLevel - 1)
        levelStepper.value = Double(Game.shared.level)
        levelStepper.stepValue = 1
        levelStepper.tintColor = userInterfaceColor
        
        maxNumberStepper.maximumValue = Double(Game.shared.maxPossibleNumber)
        maxNumberStepper.value = Double(Game.shared.maxNumber)
        maxNumberStepper.stepValue = 5
        maxNumberStepper.tintColor = userInterfaceColor
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
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
    
    @IBAction func levelStepperValueChanged(_ sender: UIStepper) {
        let level = Int(sender.value)
        Game.shared.level = level
        levelLabel.text = String(level)
        delegate?.levelChanged(to: level)
    }
    
    @IBAction func maxNumberStepperValueChanged(_ sender: UIStepper) {
        let maxNumber = Int(sender.value)
        Game.shared.rows += 1
        maxNumberLabel.text = String(maxNumber)
        delegate?.maxNumberChanged(to: maxNumber)
    }
}
