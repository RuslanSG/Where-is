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
    
    func darkModeStateChanged(to state: Bool)

}

class SettingsTableViewController: UITableViewController {
   
    @IBOutlet var switchers: [UISwitch]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var cells: [UITableViewCell]!
    
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
    
    @IBOutlet weak var darkModeSwitcher: UISwitch!
    
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
    
    // MARK: - Colors
    
    var darkMode: Bool! {
        didSet {
            switchAppearanceTo(darkMode: darkMode)
        }
    }
    
    private let navigationBarColor          = (darkMode: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1), lightMode: #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9725490196, alpha: 1))
    private let cellsColor                  = (darkMode: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1), lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    private let tableViewBackgroundColor    = (darkMode: #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09019607843, alpha: 1), lightMode: #colorLiteral(red: 0.9411764706, green: 0.937254902, blue: 0.9607843137, alpha: 1))
    private let tableViewSeparatorColor     = (darkMode: #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1843137255, alpha: 1), lightMode: #colorLiteral(red: 0.8274509804, green: 0.8235294118, blue: 0.8392156863, alpha: 1))
    private let swithersTintColor           = (darkMode: #colorLiteral(red: 0.262745098, green: 0.2588235294, blue: 0.2705882353, alpha: 1), lightMode: #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1))
    
    override func viewWillAppear(_ animated: Bool) {
        doneButton.tintColor = userInterfaceColor
        switchers.forEach { $0.onTintColor = userInterfaceColor }
        
        shuffleNumbersModeSwitcher.setOn(shuffleNumbersMode, animated: false)
        colorfulNumbersModeSwitcher.setOn(colorfulNumbersMode, animated: false)
        colorModeSwitcher.setOn(colorfulCellsMode, animated: false)
        shuffleColorsModeSwitcher.setOn(shuffleColorsMode, animated: false)
        winkNumbersModeSwitcher.setOn(winkNumbersMode, animated: false)
        winkColorsModeSwitcher.setOn(winkColorsMode, animated: false)

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
        
        darkModeSwitcher.setOn(darkMode, animated: false)
        darkModeSwitcher.onTintColor = userInterfaceColor
        
        darkMode ? cells.forEach { $0.backgroundColor = cellsColor.darkMode } :
                   cells.forEach { $0.backgroundColor = cellsColor.lightMode }
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
    
    @IBAction func darkModeSwitcherValueChanged(_ sender: UISwitch) {
        darkMode = sender.isOn
        delegate?.darkModeStateChanged(to: sender.isOn)
    }
    
    // MARK: - Helping Methods
    
    private func switchAppearanceTo(darkMode: Bool) {
        if darkMode {
            navigationController?.navigationBar.barTintColor = navigationBarColor.darkMode
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
            tableView.backgroundColor = tableViewBackgroundColor.darkMode
            cells.forEach { $0.backgroundColor = cellsColor.darkMode }
            tableView.separatorColor = tableViewSeparatorColor.darkMode
            switchers.forEach { (switcher) in
                switcher.tintColor = swithersTintColor.darkMode
            }
            labels.forEach { (label) in
                label.textColor = .white
            }
        } else {
            navigationController?.navigationBar.barTintColor = navigationBarColor.lightMode
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
            tableView.backgroundColor = tableViewBackgroundColor.lightMode
            cells.forEach { $0.backgroundColor = cellsColor.lightMode }
            tableView.separatorColor = tableViewSeparatorColor.lightMode
            switchers.forEach { (switcher) in
                switcher.tintColor = swithersTintColor.lightMode
            }
            labels.forEach { (label) in
                label.textColor = .black
            }
        }
    }
    
}
