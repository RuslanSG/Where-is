//
//  SettingsTableViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 13.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
   
    @IBOutlet var switchers: [UISwitch]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var cells: [UITableViewCell]!
    @IBOutlet var steppers: [UIStepper]!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var levelStepper: UIStepper!
    
    @IBOutlet weak var darkModeSwitcher: UISwitch!
    @IBOutlet weak var automaticDarkModeSwitcher: UISwitch!
    
    var game: Game!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var appearance: Appearance!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInputComponents()
        setupColors(animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChangedNotification(notification:)),
            name: Notification.Name.DarkModeStateDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup UI
    
    private func setupInputComponents() {
        doneButton.tintColor = appearance.userInterfaceColor
        switchers.forEach { $0.onTintColor = appearance.userInterfaceColor }
        
        levelLabel.text = String(game.level)
        
        levelStepper.maximumValue = Double(game.maxLevel)
        levelStepper.minimumValue = Double(game.minLevel)
        levelStepper.value = Double(game.level)
        levelStepper.stepValue = 1
        levelStepper.tintColor = appearance.userInterfaceColor
        
        darkModeSwitcher.setOn(appearance.darkMode, animated: false)
        darkModeSwitcher.isEnabled = !appearance.automaticDarkMode
        
        automaticDarkModeSwitcher.setOn(appearance.automaticDarkMode, animated: false)
    }
    
    @objc private func setupColors(animated: Bool) {
        if let currentColor = self.doneButton.tintColor {
            self.doneButton.tintColor = self.appearance.switchColorForAnotherScheme(currentColor)
        }
        self.tableView.backgroundColor = self.appearance.tableViewBackgroundColor
        self.tableView.separatorColor = self.appearance.tableViewSeparatorColor
        
        self.steppers.forEach { $0.tintColor = self.appearance.userInterfaceColor }
        self.cells.forEach { $0.backgroundColor = self.appearance.tableViewCellColor }
        
        self.navigationController?.navigationBar.barStyle = self.appearance.darkMode ? .black : .default
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : (self.appearance.darkMode ? UIColor.white : UIColor.black)]
        self.labels.forEach { $0.textColor = self.appearance.darkMode ? .white : .black }
        
        for switcher in self.switchers {
            switcher.tintColor = self.appearance.switcherTintColor
            switcher.onTintColor = self.appearance.userInterfaceColor
        }
    }
        
    // MARK: - Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func levelStepperValueChanged(_ sender: UIStepper) {
        let level = Int(sender.value)
        levelLabel.text = String(level)
        game.level = level
    }
    
    @IBAction func darkModeSwitcherValueChanged(_ sender: UISwitch) {
        if sender.isOn != appearance.darkMode {
            appearance.darkMode = sender.isOn
        }
    }
    
    @IBAction func automaticDarkModeSwitcherValueChanged(_ sender: UISwitch) {
        appearance.automaticDarkMode = sender.isOn
        darkModeSwitcher.isEnabled = !sender.isOn
    }
    
    // MARK: - Notifications
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        setupColors(animated: true)
        darkModeSwitcher.setOn(appearance.darkMode, animated: true)
    }

}
