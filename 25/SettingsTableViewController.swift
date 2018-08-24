//
//  SettingsTableViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 13.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
    
    func shuffleColorsModeStateChanged(to state: Bool)
    func shuffleNumbersModeStateChanged(to state: Bool)
    func colorfulCellsModeStateChanged(to state: Bool)
    func winkModeStateChanged(to state: Bool)
    func levelChanged(to level: Int)
    func maxNumberChanged(to maxNumber: Int)

}

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var colorModeSwitcher: UISwitch!
    @IBOutlet weak var shuffleColorsModeSwitcher: UISwitch!
    @IBOutlet weak var shuffleNumbersModeSwitcher: UISwitch!
    @IBOutlet weak var winkModeSwitcher: UISwitch!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var maxNumberLabel: UILabel!
    
    @IBOutlet weak var levelStepper: UIStepper!
    @IBOutlet weak var maxNumberStepper: UIStepper!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var delegate: SettingsTableViewControllerDelegate?
    
    var userInterfaceColor: UIColor!
    
    var colorfulCellsMode: Bool!
    var shuffleColorsMode: Bool!
    var shuffleNumbersMode: Bool!
    var winkMode: Bool!
    var level: Int!
    var maxNumber: Int!
    var maxLevel: Int!
    var maxPossibleNumber: Int!
    var minPossibleNumber: Int!
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: Use OutletCollections
        colorModeSwitcher.setOn(colorfulCellsMode, animated: false)
        colorModeSwitcher.onTintColor = userInterfaceColor

        shuffleColorsModeSwitcher.setOn(shuffleColorsMode, animated: false)
        shuffleColorsModeSwitcher.onTintColor = userInterfaceColor

        shuffleNumbersModeSwitcher.setOn(shuffleNumbersMode, animated: false)
        shuffleNumbersModeSwitcher.onTintColor = userInterfaceColor

        winkModeSwitcher.setOn(winkMode, animated: false)
        winkModeSwitcher.onTintColor = userInterfaceColor

        doneButton.tintColor = userInterfaceColor

        if !colorModeSwitcher.isOn {
            shuffleColorsModeSwitcher.isEnabled = false
            shuffleColorsModeSwitcher.setOn(false, animated: false)
        }

        levelLabel.text = String(level)
        maxNumberLabel.text = String(maxNumber)

        levelStepper.maximumValue = Double(maxLevel - 1)
        levelStepper.value = Double(level)
        levelStepper.stepValue = 1
        levelStepper.tintColor = userInterfaceColor

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
    
    @IBAction func colorSwitcherValueChanged(_ sender: UISwitch) {
        delegate?.colorfulCellsModeStateChanged(to: sender.isOn)
        if !sender.isOn && shuffleColorsModeSwitcher.isOn {
            shuffleColorsModeSwitcher.setOn(false, animated: true)
        }
        shuffleColorsModeSwitcher.isEnabled = sender.isOn
    }
    
    @IBAction func shuffleColorsModeSwitcherValueChanged(_ sender: UISwitch) {
       delegate?.shuffleColorsModeStateChanged(to: sender.isOn)
    }
    
    @IBAction func shuffleNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        delegate?.shuffleNumbersModeStateChanged(to: sender.isOn)
    }
    
    @IBAction func winkModeSwitcherValueChanged(_ sender: UISwitch) {
        delegate?.winkModeStateChanged(to: sender.isOn)
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
