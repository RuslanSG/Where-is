//
//  SettingsTableViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 13.08.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import CoreLocation

class SettingsTableViewController: UITableViewController {
   
    private enum Strings {
        static let LocationServicesEnabledFooterText = "Чтобы определить время захода и восхода солнца, необходимо разово получить данные о Вашем примерном местоположении. Эта информация будет храниться только на данном устройстве."
        static let LocationServicesDisabledFooterText = "Для работы автоматического темного режима, пожалуйста, предоставьте приложению доступ к Вашему примерному местоположению. Эта информация будет храниться только на данном устройстве."
    }
    
    @IBOutlet var switchers: [UISwitch]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var cells: [UITableViewCell]!
    
    @IBOutlet var firstCell: UITableViewCell!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var darkModeSwitcher: UISwitch!
    @IBOutlet weak var automaticDarkModeSwitcher: UISwitch!
    
    private var levelButtons = [UIButton]()
    
    var game: Game!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var appearance: Appearance!
    
    private var lastPressedLevelButton: UIButton?
    
    private var automaticDarkModeEnabled = false
    
    private let levelButtonSideSize: CGFloat = 50.0
    private let infinityLevelButtonHeightCoeff: CGFloat = 1.7 /// higher coeff = lower height revatavely to the regular level button
    
    private let levelButtonsGridParameters: (rows: Int, colums: Int) = {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return (rows: 7, colums: 5)
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            return (rows: 4, colums: 10)
        }
        return (rows: 0, colums: 0)
    }()
    
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
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
        setupLevelButtonsStackView(count: game.maxLevel)
        
        darkModeSwitcher.setOn(appearance.darkMode, animated: false)
        darkModeSwitcher.isEnabled = !appearance.automaticDarkMode
        
        setupAutomaticDarkModeSwitcher()
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
    }
    
    private func setupLevelButtonsStackView(count: Int) {
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .equalSpacing
        verticalStackView.alignment = .fill
        
        for i in 0..<levelButtonsGridParameters.rows - 1 { /// minus Infinity Level button
            let horizontalStackView = UIStackView()
            horizontalStackView.axis = .horizontal
            horizontalStackView.distribution = .equalSpacing
            horizontalStackView.alignment = .fill
            
            for j in 1...levelButtonsGridParameters.colums {
                let level = j + i * levelButtonsGridParameters.colums
                horizontalStackView.addArrangedSubview(setupLevelButton(for: level))
            }
            verticalStackView.addArrangedSubview(horizontalStackView)
        }
        
        /// Adding Infinity Level button
        verticalStackView.addArrangedSubview(setupLevelButton(for: 0))
        
        self.firstCell.contentView.addSubview(verticalStackView)
        
        /// verticalStackView constraints
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.topAnchor.constraint(equalTo: self.firstCell.contentView.topAnchor, constant: 10.0).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: self.firstCell.contentView.bottomAnchor, constant: -10.0).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: self.firstCell.contentView.leftAnchor, constant: 16.0).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: self.firstCell.contentView.rightAnchor, constant: -16.0).isActive = true
        
        updateLevelButtons()
    }
    
    private func setupAutomaticDarkModeSwitcher() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                automaticDarkModeSwitcher.setOn(false, animated: true)
                appearance.automaticDarkMode = false
                self.automaticDarkModeEnabled = false
                darkModeSwitcher.isEnabled = true
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                automaticDarkModeSwitcher.setOn(appearance.automaticDarkMode, animated: false)
                darkModeSwitcher.isEnabled = !appearance.automaticDarkMode
                self.automaticDarkModeEnabled = true
            }
        } else {
            automaticDarkModeSwitcher.setOn(false, animated: true)
            appearance.automaticDarkMode = false
            darkModeSwitcher.isEnabled = true
            self.automaticDarkModeEnabled = false
        }
        tableView.reloadSections(IndexSet.init(integer: 1), with: .none)
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
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                showLocationServicesAlertController(sender: sender)
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                appearance.automaticDarkMode = sender.isOn
                darkModeSwitcher.isEnabled = !sender.isOn
            }
        } else {
            showLocationServicesAlertController(sender: sender)
        }
    }
    
    @objc private func levelButtonPressed(_ sender: UIButton) {
        game.level = sender.tag
        selectLevelButton(sender)
    }
    
    // MARK: - Data Source
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            if self.automaticDarkModeEnabled {
                return Strings.LocationServicesEnabledFooterText
            } else {
                return Strings.LocationServicesDisabledFooterText
            }
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 0 {
            let spacingCoeff = 1.25
            return (self.levelButtonSideSize * CGFloat(self.levelButtonsGridParameters.rows - 1) + self.levelButtonSideSize / self.infinityLevelButtonHeightCoeff) * CGFloat(spacingCoeff)
        }
        return 44.0
    }
    
    // MARK: - Notifications
    
    @objc func darkModeStateChangedNotification(notification: Notification) {
        darkModeSwitcher.setOn(appearance.darkMode, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupColors()
        }
    }
    
    @objc private func didBecomeActive() {
        setupAutomaticDarkModeSwitcher()
    }
    
    // MARK: - Location Services Alert Controller
    
    private func showLocationServicesAlertController(sender: UISwitch) {
        let alertController = UIAlertController(title: "Предоставьте доступ к геолокации", message: "Чтобы определить время захода и восхода солнца, необходимо разово получить данные о Вашем примерном местоположении. Эта информация будет храниться только на данном устройстве.", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Отмена", style: .cancel) { (action: UIAlertAction) in
            sender.setOn(false, animated: true)
        }
        
        let action2 = UIAlertAction(title: "Перейти в настройки", style: .default) { (action: UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Hepling methods
    
    private func setupLevelButton(for level: Int) -> UIButton {
        let fontSize: CGFloat = 25.0
        let cornerRadius: CGFloat = 8.0
        let title = level == 0 ? "∞" : String(level)
        let side = level == 0 ? levelButtonSideSize / self.infinityLevelButtonHeightCoeff : levelButtonSideSize
        
        let levelButton = UIButton()
        levelButton.setTitle(title, for: .normal)
        levelButton.setTitleColor(.white, for: .normal)
        levelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        levelButton.tag = level
        levelButton.layer.cornerRadius = cornerRadius
        levelButton.translatesAutoresizingMaskIntoConstraints = false
        levelButton.heightAnchor.constraint(equalToConstant: side).isActive = true
        levelButton.widthAnchor.constraint(equalToConstant: side).isActive = true
        levelButton.addTarget(self, action: #selector(levelButtonPressed(_:)), for: .touchUpInside)
        
        self.levelButtons.append(levelButton)
        
        return levelButton
    }
    
    /// Setups Level Buttons colors and set selected one
    private func updateLevelButtons() {
        for levelButton in levelButtons {
            if game.levelIsAvailable(levelButton.tag) {
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
