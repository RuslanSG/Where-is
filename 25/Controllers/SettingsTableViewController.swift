//
//  SettingsTableViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 13.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
//import QuartzCore

class SettingsTableViewController: UITableViewController {
   
    @IBOutlet var switchers: [UISwitch]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var cells: [UITableViewCell]!
    @IBOutlet var levelButtons: [UIButton]!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var darkModeSwitcher: UISwitch!
    @IBOutlet weak var automaticDarkModeSwitcher: UISwitch!
    
    var game: Game!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var appearance: Appearance!
    
    private var lastPressedLevelButton: UIButton?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInputComponents()
        setupColors()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChangedNotification(notification:)),
            name: Notification.Name.DarkModeStateDidChange,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLevelButtons()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup UI
    
    private func setupInputComponents() {
        darkModeSwitcher.setOn(appearance.darkMode, animated: false)
        darkModeSwitcher.isEnabled = !appearance.automaticDarkMode
        
        automaticDarkModeSwitcher.setOn(appearance.automaticDarkMode, animated: false)
        setupLevelButtons()
    }
    
    @objc private func setupColors() {
        self.doneButton.tintColor = self.appearance.userInterfaceColor
        self.tableView.backgroundColor = self.appearance.tableViewBackgroundColor
        self.tableView.separatorColor = self.appearance.tableViewSeparatorColor
        
        self.cells.forEach { $0.backgroundColor = self.appearance.tableViewCellColor }
        
        self.navigationController?.navigationBar.barStyle = self.appearance.darkMode ? .black : .default
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : (self.appearance.darkMode ? UIColor.white : UIColor.black)]
        self.labels.forEach { $0.textColor = self.appearance.darkMode ? .white : .black }
        
        for switcher in self.switchers {
            switcher.tintColor = self.appearance.switcherTintColor
            switcher.onTintColor = self.appearance.userInterfaceColor
        }
        
        for availableLevel in game.availableLevels {
            for levelButton in levelButtons {
                if levelButton.tag == availableLevel {
                    levelButton.backgroundColor = appearance.userInterfaceColor
                }
            }            
        }
    }
        
    // MARK: - Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
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
    
    @objc private func levelButtonPressed(_ sender: UIButton) {
        game.level = sender.tag
        selectLevelButton(sender)
    }
    
    // MARK: - Notifications
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        darkModeSwitcher.setOn(appearance.darkMode, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupColors()
        }
    }
    
    // MARK: - Hepling methods
    
    /// Initial setup of Level Buttons
    private func setupLevelButtons() {
        for levelButton in levelButtons {
            if let text = levelButton.titleLabel?.text {
                levelButton.tag = Int(text) ?? 0
            }
            levelButton.layer.cornerRadius = levelButton.frame.size.height / 6
            levelButton.setTitleColor(.white, for: .normal)
            levelButton.addTarget(self, action: #selector(levelButtonPressed(_:)), for: .touchUpInside)
        }
        updateLevelButtons()
    }
    
    /// Setups Level Buttons colors and set selected one
    private func updateLevelButtons() {
        for levelButton in levelButtons {
            if game.availableLevels.contains(levelButton.tag) {
                levelButton.alpha = 1.0
                levelButton.backgroundColor = appearance.userInterfaceColor
                levelButton.isEnabled = true
            } else {
                levelButton.alpha = 0.5
                levelButton.backgroundColor = .gray
                levelButton.isEnabled = false
            }
            if levelButton.tag == game.level {
                selectLevelButton(levelButton)
            }
        }
    }
    
    /// Sets stroke on selected Button
    private func selectLevelButton(_ button: UIButton) {
        lastPressedLevelButton?.layer.borderWidth = 0.0
        lastPressedLevelButton = button
        button.layer.borderWidth = 3.0
        button.layer.borderColor = appearance.highlightedCellColor.cgColor
    }

}
