//
//  SettingsTableViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 13.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
    
    func colorfulNumbersModeStateChanged(to state: Bool)
    func colorfulCellsModeStateChanged(to state: Bool)
    func maxNumberChanged(to maxNumber: Int)
    func automaticDarkModeStateChanged(to state: Bool)

}

let DarkModeStateDidChangeNotification = "DarkModeStateDidChangeNotification"
let DarkModeStateUserInfoKey = "DarkModeStateUserInfoKey"

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
    
    var userInterfaceColor: UIColor!
    
    // MARK: - Colors
    
    var darkMode: Bool! {
        didSet {
            setupComponents()
            darkModeSwitcher.setOn(darkMode, animated: true)
//            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var isDay: Bool?
    
    var automaticDarkMode: Bool! {
        didSet {
            if let isDay = isDay, automaticDarkMode {
                darkMode = !isDay
                darkModeSwitcher.isEnabled = !automaticDarkMode
            }
        }
    }
    
//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        return darkMode ? .lightContent : .default
//    }
    
    private let cellsColor                  = (darkMode: #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1), lightMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    private let tableViewBackgroundColor    = (darkMode: #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09019607843, alpha: 1), lightMode: #colorLiteral(red: 0.9411764706, green: 0.937254902, blue: 0.9607843137, alpha: 1))
    private let tableViewSeparatorColor     = (darkMode: #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1843137255, alpha: 1), lightMode: #colorLiteral(red: 0.8274509804, green: 0.8235294118, blue: 0.8392156863, alpha: 1))
    private let swithersTintColor           = (darkMode: #colorLiteral(red: 0.262745098, green: 0.2588235294, blue: 0.2705882353, alpha: 1), lightMode: #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userInterfaceColorDidChangeNotification(notification:)),
            name: Notification.Name(UserInterfaceColorDidChangeNotification),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupComponents()
        
        doneButton.tintColor = userInterfaceColor
        switchers.forEach { $0.onTintColor = userInterfaceColor }
        
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
        levelStepper.tintColor = userInterfaceColor
        levelStepper.alpha = 0.5

        maxNumberStepper.maximumValue = Double(game.maxPossibleNumber)
        maxNumberStepper.minimumValue = Double(game.minPossibleNumber)
        maxNumberStepper.value = Double(game.maxNumber)
        maxNumberStepper.stepValue = 5
        maxNumberStepper.tintColor = userInterfaceColor
        
        darkModeSwitcher.setOn(darkMode, animated: false)
        darkModeSwitcher.isEnabled = !automaticDarkMode
        
        automaticDarkModeSwitcher.setOn(automaticDarkMode, animated: false)
        
        darkMode ? cells.forEach { $0.backgroundColor = cellsColor.darkMode } :
                   cells.forEach { $0.backgroundColor = cellsColor.lightMode }
        
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
        delegate?.colorfulNumbersModeStateChanged(to: sender.isOn)
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
        darkMode = sender.isOn
        postDarkModeStateChangedNotification()
    }
    
    @IBAction func automaticDarkModeSwitcherValueChanged(_ sender: UISwitch) {
        automaticDarkMode = sender.isOn
        darkModeSwitcher.isEnabled = !sender.isOn
        delegate?.automaticDarkModeStateChanged(to: sender.isOn)
        postDarkModeStateChangedNotification()
    }
    
    // MARK: - Notifications
    
    @objc private func userInterfaceColorDidChangeNotification(notification: Notification) {
        userInterfaceColor = notification.object as? UIColor
        setupUserInterfaceColor(with: userInterfaceColor)
    }
    
    // MARK: - Helping Methods
    
    @objc private func setupComponents() {
        if darkMode {
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
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
            navigationController?.navigationBar.barStyle = .default
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
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
    
    private func postDarkModeStateChangedNotification() {
        NotificationCenter.default.post(
            name: Notification.Name(DarkModeStateDidChangeNotification),
            object: nil,
            userInfo: [DarkModeStateUserInfoKey: darkMode]
        )
    }
    
}
