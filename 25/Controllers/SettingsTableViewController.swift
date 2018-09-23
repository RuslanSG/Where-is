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
            selector: #selector(userInterfaceColorDidChangeNotification(notification:)),
            name: Notification.Name(NotificationName.userInterfaceColorDidChange.rawValue),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChangedNotification(notification:)),
            name: Notification.Name(NotificationName.darkModeStateDidChange.rawValue),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupComponents()
        
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
//            if winkColorsModeSwitcher.isOn {
//                winkColorsModeSwitcher.setOn(false, animated: true)
//            }
            if colorfulNumbersModeSwitcher.isOn {
                colorfulNumbersModeSwitcher.setOn(false, animated: true)
            }
        }
        shuffleColorsModeSwitcher.isEnabled = sender.isOn
//        winkColorsModeSwitcher.isEnabled = sender.isOn
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
            darkModeSwitcher.isEnabled = true
        }
        automaticDarkMode.isOn = sender.isOn
        darkModeSwitcher.isEnabled = !sender.isOn
    }
    
    // MARK: - Notifications
    
    @objc private func userInterfaceColorDidChangeNotification(notification: Notification) {
//        appearance.userInterfaceColor = notification.object as? UIColor
//        setupUserInterfaceColor(with: appearance.userInterfaceColor)
    }
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        setupComponents()
    }
    
    // MARK: - Helping Methods
    
    @objc private func setupComponents() {
        if appearance.darkMode {
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            tableView.backgroundColor = appearance.tableViewBackgroundColor.darkMode
            cells.forEach { $0.backgroundColor = appearance.cellsColor.darkMode }
            tableView.separatorColor = appearance.tableViewSeparatorColor.darkMode
            switchers.forEach { (switcher) in
                switcher.tintColor = appearance.swithersTintColor.darkMode
            }
            labels.forEach { (label) in
                label.textColor = .white
            }
        } else {
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
            tableView.backgroundColor = appearance.tableViewBackgroundColor.lightMode
            cells.forEach { $0.backgroundColor = appearance.cellsColor.lightMode }
            tableView.separatorColor = appearance.tableViewSeparatorColor.lightMode
            switchers.forEach { (switcher) in
                switcher.tintColor = appearance.swithersTintColor.lightMode
            }
            labels.forEach { (label) in
                label.textColor = .black
            }
        }
    }
    
    private func setupUserInterfaceColor(with color: UIColor) {
        self.switchers.forEach { $0.onTintColor = color }
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0.0,
            options: [],
            animations: {
                self.levelStepper.tintColor = color
                self.maxNumberStepper.tintColor = color
                self.doneButton.tintColor = color
        })
    }
    
}
