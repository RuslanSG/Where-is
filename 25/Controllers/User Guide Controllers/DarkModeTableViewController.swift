//
//  DarkModeViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/29/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import CoreLocation

protocol DarkModeViewControllerDelegate {
    func automaticDarkModeStateChanged(to state: Bool)
}

class DarkModeTableViewController: UITableViewController {
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var cells: [UITableViewCell]!
    
    @IBOutlet var darkerCells: [UITableViewCell]!
    
    @IBOutlet weak var sunriseTimeLabel: RGAnimatedLabel!
    @IBOutlet weak var sunsetTimeLabel: RGAnimatedLabel!
    @IBOutlet weak var locationCityLabel: RGAnimatedLabel!
    
    @IBOutlet weak var switcher: UISwitch!
    
    var delegate: DarkModeViewControllerDelegate?
    var appearance: Appearance!
    
    private let daytime = Daytime()
    private var cityName = "?"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(darkModeStateChangedNotification(_:)),
            name: Notification.Name.DarkModeStateDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userLocationDidUpdateNotification(_:)),
            name: Notification.Name.UserLocationDidUpdate,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @IBAction func automaticDarkModeSwitcherValueChanged(_ sender: UISwitch) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                showLocationServicesAlertController(sender: sender)
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                appearance.automaticDarkMode = sender.isOn
            }
        } else {
            showLocationServicesAlertController(sender: sender)
        }
    }
    
    // MARK: - Notifications
    
    @objc func darkModeStateChangedNotification(_ notification: Notification) {
        setupColors()
    }
    
    @objc func userLocationDidUpdateNotification(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            guard let userInfo = notification.userInfo else { return }
            guard let cityName = userInfo[Notification.UserInfoKey.CityName] as? String else { return }
            self.cityName = cityName
            self.setupInfo()
        }
    }
    
    @objc private func didBecomeActive() {
        setupAutomaticDarkModeSwitcher()
    }
    
    // MARK: - Setuping
    
    private func setupColors() {
        if appearance.darkMode {
            let duration = 0.6
            let delay = 0.0
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: duration,
                delay: delay,
                options: .curveEaseInOut,
                animations: {
                    self.labels.forEach { $0.textColor = self.appearance.textColor }
                    self.cells.forEach { $0.backgroundColor = self.appearance.tableViewCellColor }
                    self.darkerCells.forEach { $0.backgroundColor = self.appearance.tableViewBackgroundColor }
                    self.tableView.backgroundColor = self.appearance.tableViewBackgroundColor
                    self.tableView.tableFooterView?.backgroundColor = self.appearance.tableViewBackgroundColor
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
                self.switcher.tintColor = self.appearance.switcherTintColor
                self.tableView.separatorColor = self.appearance.tableViewSeparatorColor
            }
        }
    }
    
    private func setupInfo() {
        guard let sunriseTime = daytime.sunriseTime else { return }
        guard let sunsetTime = daytime.sunsetTime else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let sunriseTimeString = dateFormatter.string(from: sunriseTime)
        let sunsetTimeString = dateFormatter.string(from: sunsetTime)
        sunriseTimeLabel.setText(sunriseTimeString, animated: true)
        sunsetTimeLabel.setText(sunsetTimeString, animated: true)
        locationCityLabel.setText(self.cityName, animated: true)
    }
    
    private func setupAutomaticDarkModeSwitcher() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                switcher.setOn(false, animated: true)
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                switcher.setOn(appearance.automaticDarkMode, animated: false)
            }
        } else {
            switcher.setOn(false, animated: true)
        }
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

}
