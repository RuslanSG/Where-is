//
//  SettingsTableViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 13.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
    
    func colorfulCellsModeStateChanged(to state: Bool)
    func maxNumberChanged(to maxNumber: Int)

}

class SettingsTableViewController: UITableViewController {
   
    @IBOutlet var switchers: [UISwitch]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var cells: [UITableViewCell]!
    @IBOutlet var steppers: [UIStepper]!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var shuffleNumbersModeSwitcher: UISwitch!
    @IBOutlet weak var colorfulNumbersModeSwitcher: UISwitch!
    @IBOutlet weak var winkNumbersModeSwitcher: UISwitch!
    @IBOutlet weak var swapNumbersModeSwitcher: UISwitch!

    @IBOutlet weak var colorModeSwitcher: UISwitch!
    @IBOutlet weak var shuffleColorsModeSwitcher: UISwitch!
    @IBOutlet weak var winkColorsModeSwitcher: UISwitch!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var maxNumberLabel: UILabel!
    
    @IBOutlet weak var levelStepper: UIStepper!
    @IBOutlet weak var maxNumberStepper: UIStepper!
    
    @IBOutlet weak var darkModeSwitcher: UISwitch!
    @IBOutlet weak var automaticDarkModeSwitcher: UISwitch!
    
    var game: Game!
    
    var delegate: SettingsTableViewControllerDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var appearance: Appearance!
    var automaticDarkMode: AutomaticDarkMode!
    
//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        return darkMode ? .lightContent : .default
//    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChangedNotification(notification:)),
            name: Notification.Name(StringKeys.NotificationName.darkModeStateDidChange.rawValue),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupColors(animated: false)
        
        doneButton.tintColor = appearance.userInterfaceColor
        switchers.forEach { $0.onTintColor = appearance.userInterfaceColor }
        
        shuffleNumbersModeSwitcher.setOn(game.shuffleNumbersMode, animated: false)
        colorfulNumbersModeSwitcher.setOn(game.colorfulNumbersMode, animated: false)
        winkNumbersModeSwitcher.setOn(game.winkNumbersMode, animated: false)
        swapNumbersModeSwitcher.setOn(game.swapNumbersMode, animated: false)

        colorModeSwitcher.setOn(game.colorfulCellsMode, animated: false)
        shuffleColorsModeSwitcher.setOn(game.shuffleColorsMode, animated: false)
        winkColorsModeSwitcher.setOn(game.winkColorsMode, animated: false)
        
        winkColorsModeSwitcher.isEnabled = false // Disabled for testing

        if !game.colorfulCellsMode {
            shuffleColorsModeSwitcher.isEnabled = false
            shuffleColorsModeSwitcher.setOn(false, animated: false)
            
            winkColorsModeSwitcher.isEnabled = false
            winkColorsModeSwitcher.setOn(false, animated: false)
            
            colorfulNumbersModeSwitcher.isEnabled = false
            colorfulNumbersModeSwitcher.setOn(false, animated: false)
        }
        if game.swapNumbersMode {
            winkNumbersModeSwitcher.isEnabled = false
            shuffleNumbersModeSwitcher.isEnabled = false
        }
        if game.winkNumbersMode || game.shuffleColorsMode {
            swapNumbersModeSwitcher.isEnabled = false
        }

        levelLabel.text = String(game.level)
        maxNumberLabel.text = String(game.maxNumber)

        levelStepper.isEnabled = false // Disabled for testing
        levelStepper.maximumValue = Double(game.maxLevel)
        levelStepper.minimumValue = Double(game.minLevel)
        levelStepper.value = Double(game.level)
        levelStepper.stepValue = 1
        levelStepper.tintColor = appearance.userInterfaceColor
        levelStepper.alpha = 0.5

        maxNumberStepper.maximumValue = Double(game.maxPossibleNumber)
        maxNumberStepper.minimumValue = Double(game.minPossibleNumber)
        maxNumberStepper.value = Double(game.maxNumber)
        maxNumberStepper.stepValue = 5
        maxNumberStepper.tintColor = appearance.userInterfaceColor
        
        darkModeSwitcher.setOn(appearance.darkMode, animated: false)
        darkModeSwitcher.isEnabled = !automaticDarkMode.isOn
        
        automaticDarkModeSwitcher.setOn(automaticDarkMode.isOn, animated: false)
        
        appearance.darkMode ? cells.forEach { $0.backgroundColor = appearance.cellsColor.darkMode } :
                              cells.forEach { $0.backgroundColor = appearance.cellsColor.lightMode }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    // MARK: - Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func shuffleNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        game.shuffleNumbersMode = sender.isOn
    }
    
    @IBAction func colorfulNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        game.colorfulNumbersMode = sender.isOn
    }
    
    @IBAction func winkNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        game.winkNumbersMode = sender.isOn
        swapNumbersModeSwitcher.isEnabled = !sender.isOn
    }
    
    @IBAction func swapNumbersModeSwitcherValueChanged(_ sender: UISwitch) {
        game.swapNumbersMode = sender.isOn
        winkNumbersModeSwitcher.isEnabled = !sender.isOn
        shuffleNumbersModeSwitcher.isEnabled = !sender.isOn
    }
    
    @IBAction func colorfulCellsSwitcherValueChanged(_ sender: UISwitch) {
        game.colorfulCellsMode = sender.isOn
        delegate?.colorfulCellsModeStateChanged(to: sender.isOn)
        if !sender.isOn {
            if shuffleColorsModeSwitcher.isOn {
                shuffleColorsModeSwitcher.setOn(false, animated: true)
            }
            if colorfulNumbersModeSwitcher.isOn {
                colorfulNumbersModeSwitcher.setOn(false, animated: true)
            }
        }
        shuffleColorsModeSwitcher.isEnabled = sender.isOn
        colorfulNumbersModeSwitcher.isEnabled = sender.isOn
    }
    
    @IBAction func shuffleColorsModeSwitcherValueChanged(_ sender: UISwitch) {
        game.shuffleColorsMode = sender.isOn
    }
    
    @IBAction func winkColorsModeSwitcherValueChanged(_ sender: UISwitch) {
        game.winkColorsMode = sender.isOn
    }
    
    
    @IBAction func levelStepperValueChanged(_ sender: UIStepper) {
        let level = Int(sender.value)
        levelLabel.text = String(level)
        game.level = level
    }
    
    @IBAction func maxNumberStepperValueChanged(_ sender: UIStepper) {
        let maxNumber = Int(sender.value)
        maxNumberLabel.text = String(maxNumber)
        delegate?.maxNumberChanged(to: maxNumber)
    }
    
    @IBAction func darkModeSwitcherValueChanged(_ sender: UISwitch) {
        appearance.darkMode = sender.isOn
    }
    
    @IBAction func automaticDarkModeSwitcherValueChanged(_ sender: UISwitch) {
        if let isDay = automaticDarkMode.isDay, sender.isOn == true {
            appearance.darkMode = !isDay
        }
        automaticDarkMode.isOn = sender.isOn
        darkModeSwitcher.isEnabled = !sender.isOn
        darkModeSwitcher.setOn(appearance.darkMode, animated: true)
    }
    
    // MARK: - Notifications
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        setupColors(animated: true)
    }
    
    @objc private func didBecomeActive() {
        automaticDarkMode.setDarkModeByCurrentTime()
    }
    
    // MARK: - Helping Methods
    
    @objc private func setupColors(animated: Bool) {
        let duration = 0.3
        
        let animatedColorChanger = {
            if let currentColor = self.doneButton.tintColor {
                self.doneButton.tintColor = self.appearance.switchColorForAnotherScheme(currentColor)
            }
            self.tableView.backgroundColor = self.appearance.darkMode ? self.appearance.tableViewBackgroundColor.darkMode : self.appearance.tableViewBackgroundColor.lightMode
            self.tableView.separatorColor = self.appearance.darkMode ? self.appearance.tableViewSeparatorColor.darkMode : self.appearance.tableViewSeparatorColor.lightMode

            self.steppers.forEach { $0.tintColor = self.appearance.userInterfaceColor }
            self.cells.forEach { $0.backgroundColor = self.appearance.darkMode ? self.appearance.cellsColor.darkMode : self.appearance.cellsColor.lightMode }
            
        }
        
        let colorChanger = {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
                self.navigationController?.navigationBar.barStyle = self.appearance.darkMode ? .black : .default
                self.navigationController?.navigationBar.titleTextAttributes =
                    [NSAttributedString.Key.foregroundColor : (self.appearance.darkMode ? UIColor.white : UIColor.black)]
                self.labels.forEach { $0.textColor = self.appearance.darkMode ? .white : .black }
                
                for switcher in self.switchers {
                    switcher.tintColor = self.appearance.darkMode ? self.appearance.swithersTintColor.darkMode : self.appearance.swithersTintColor.lightMode
                    switcher.onTintColor = self.appearance.userInterfaceColor
                }
            }
        }
        
        if animated {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: 0.0,
                options: [],
                animations: {
                    animatedColorChanger()
            })
            colorChanger()
        } else {
            animatedColorChanger()
            colorChanger()
        }
        
        
        
    }
    

    
}
