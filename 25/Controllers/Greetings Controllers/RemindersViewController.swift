//
//  RemindersViewController.swift
//  25
//
//  Created by Ruslan Gritsenko on 9/29/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit
import UserNotifications

class RemindersViewController: UIViewController {
    
    // MARK: - Actions
    
    @IBAction func switcherValueChanged(_ sender: UISwitch) {
        registerForPushNotifications()
    }
    
    // MARK: - User Notifications
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

}
