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
    
    @IBOutlet weak var colorModeSwitcher: UISwitch!
    @IBOutlet weak var shuffleColorsModeSwitcher: UISwitch!
    @IBOutlet weak var shuffleNumbersModeSwitcher: UISwitch!
    @IBOutlet weak var winkModeSwitcher: UISwitch!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var maxNumberLabel: UILabel!
    
    @IBOutlet weak var levelStepper: UIStepper!
    @IBOutlet weak var maxNumberStepper: UIStepper!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var userInterfaceColor: UIColor!
    
    var delegate: SettingsTableViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: Use OutletCollections
        colorModeSwitcher.setOn(Game.shared.colorfulCellsMode, animated: false)
        colorModeSwitcher.onTintColor = userInterfaceColor
        
        shuffleColorsModeSwitcher.setOn(Game.shared.shuffleColorsMode, animated: false)
        shuffleColorsModeSwitcher.onTintColor = userInterfaceColor
        
        shuffleNumbersModeSwitcher.setOn(Game.shared.shuffleNumbersMode, animated: false)
        shuffleNumbersModeSwitcher.onTintColor = userInterfaceColor
        
        winkModeSwitcher.setOn(Game.shared.winkMode, animated: false)
        winkModeSwitcher.onTintColor = userInterfaceColor
        
        doneButton.tintColor = userInterfaceColor
        
        if !colorModeSwitcher.isOn {
            shuffleColorsModeSwitcher.isEnabled = false
            shuffleColorsModeSwitcher.setOn(false, animated: false)
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
        Game.shared.colorfulCellsMode = sender.isOn
        Game.shared.shuffleColorsMode = false
        delegate?.colorModeStateChanged(to: sender.isOn)
        if !sender.isOn && shuffleColorsModeSwitcher.isOn {
            shuffleColorsModeSwitcher.setOn(false, animated: true)
        }
        shuffleColorsModeSwitcher.isEnabled = sender.isOn
    }
    
    @IBAction func shuffleColorsModeSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.shuffleColorsMode = sender.isOn
    }
    
    @IBAction func shuffleNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.shuffleNumbersMode = sender.isOn
    }
    
    @IBAction func winkModeSwitcherValueChanged(_ sender: UISwitch) {
        Game.shared.winkMode = sender.isOn
        if sender.isOn {
            //delegate?.winkModeIsOn()
        }
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
