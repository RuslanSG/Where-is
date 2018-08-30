//
//  SettingsTableViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 13.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
    
    func shuffleNumbersModeStateChanged(to state: Bool)
    func colorfulNumbersModeStateChanged(to state: Bool)
    func winkNumbersModeStateChanged(to state: Bool)

    func colorfulCellsModeStateChanged(to state: Bool)
    func shuffleColorsModeStateChanged(to state: Bool)
    func winkColorsModeStateChanged(to state: Bool)
    
    func levelChanged(to level: Int)
    func maxNumberChanged(to maxNumber: Int)

}

class SettingsTableViewController: UITableViewController {
   
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var shuffleNumbersModeSwitcher: UISwitch!
    @IBOutlet weak var colorfulNumbersModeSwitcher: UISwitch!
    @IBOutlet weak var winkNumbersModeSwitcher: UISwitch!

    @IBOutlet weak var colorModeSwitcher: UISwitch!
    @IBOutlet weak var shuffleColorsModeSwitcher: UISwitch!
    @IBOutlet weak var winkColorsModeSwitcher: UISwitch!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var maxNumberLabel: UILabel!
    
    @IBOutlet weak var levelStepper: UIStepper!
    @IBOutlet weak var maxNumberStepper: UIStepper!
    
    var delegate: SettingsTableViewControllerDelegate?
    
    var userInterfaceColor: UIColor!
    
    var shuffleNumbersMode: Bool!
    var colorfulNumbersMode: Bool!
    var winkNumbersMode: Bool!
    
    var colorfulCellsMode: Bool!
    var shuffleColorsMode: Bool!
    var winkColorsMode: Bool!
    
    var level: Int!
    var maxNumber: Int!
    
    var maxLevel: Int!
    var minLevel: Int!
    var maxPossibleNumber: Int!
    var minPossibleNumber: Int!
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: Use OutletCollections
        shuffleNumbersModeSwitcher.setOn(shuffleNumbersMode, animated: false)
        shuffleNumbersModeSwitcher.onTintColor = userInterfaceColor
        
        colorfulNumbersModeSwitcher.setOn(colorfulNumbersMode, animated: false)
        colorfulNumbersModeSwitcher.onTintColor = userInterfaceColor
        
        colorModeSwitcher.setOn(colorfulCellsMode, animated: false)
        colorModeSwitcher.onTintColor = userInterfaceColor

        shuffleColorsModeSwitcher.setOn(shuffleColorsMode, animated: false)
        shuffleColorsModeSwitcher.onTintColor = userInterfaceColor

        winkNumbersModeSwitcher.setOn(winkNumbersMode, animated: false)
        winkNumbersModeSwitcher.onTintColor = userInterfaceColor
        
        winkColorsModeSwitcher.setOn(winkColorsMode, animated: false)
        winkColorsModeSwitcher.onTintColor = userInterfaceColor

        doneButton.tintColor = userInterfaceColor

        if !colorModeSwitcher.isOn {
            shuffleColorsModeSwitcher.isEnabled = false
            shuffleColorsModeSwitcher.setOn(false, animated: false)
            
            winkColorsModeSwitcher.isEnabled = false
            winkColorsModeSwitcher.setOn(false, animated: false)
            
            colorfulNumbersModeSwitcher.isEnabled = false
            colorfulNumbersModeSwitcher.setOn(false, animated: false)
        }

        levelLabel.text = String(level)
        maxNumberLabel.text = String(maxNumber)

        levelStepper.isEnabled = false // Disabled for testing
        levelStepper.maximumValue = Double(maxLevel)
        levelStepper.minimumValue = Double(minLevel)
        levelStepper.value = Double(level)
        levelStepper.stepValue = 1
        levelStepper.tintColor = userInterfaceColor
        levelStepper.alpha = 0.5

        maxNumberStepper.maximumValue = Double(maxPossibleNumber)
        maxNumberStepper.minimumValue = Double(minPossibleNumber)
        maxNumberStepper.value = Double(maxNumber)
        maxNumberStepper.stepValue = 5
        maxNumberStepper.tintColor = userInterfaceColor
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func shuffleNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        delegate?.shuffleNumbersModeStateChanged(to: sender.isOn)
    }
    
    @IBAction func colorfulNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        delegate?.colorfulNumbersModeStateChanged(to: sender.isOn)
    }
    
    @IBAction func winkNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        delegate?.winkNumbersModeStateChanged(to: sender.isOn)
    }
    
    @IBAction func colorSwitcherValueChanged(_ sender: UISwitch) {
        delegate?.colorfulCellsModeStateChanged(to: sender.isOn)
        if !sender.isOn {
            if shuffleColorsModeSwitcher.isOn {
                shuffleColorsModeSwitcher.setOn(false, animated: true)
            }
            if winkColorsModeSwitcher.isOn {
                winkColorsModeSwitcher.setOn(false, animated: true)
            }
            if colorfulNumbersModeSwitcher.isOn {
                colorfulNumbersModeSwitcher.setOn(false, animated: true)
            }
        }
        shuffleColorsModeSwitcher.isEnabled = sender.isOn
        winkColorsModeSwitcher.isEnabled = sender.isOn
        colorfulNumbersModeSwitcher.isEnabled = sender.isOn
    }
    
    @IBAction func shuffleColorsModeSwitcherValueChanged(_ sender: UISwitch) {
       delegate?.shuffleColorsModeStateChanged(to: sender.isOn)
    }
    
    @IBAction func winkColorsModeSwitcherValueChanged(_ sender: UISwitch) {
        delegate?.winkColorsModeStateChanged(to: sender.isOn)
    }
    
    
    @IBAction func levelStepperValueChanged(_ sender: UIStepper) {
        let level = Int(sender.value)
        levelLabel.text = String(level)
        delegate?.levelChanged(to: level)
    }
    
    @IBAction func maxNumberStepperValueChanged(_ sender: UIStepper) {
        let maxNumber = Int(sender.value)
        maxNumberLabel.text = String(maxNumber)
        delegate?.maxNumberChanged(to: maxNumber)
    }
}
