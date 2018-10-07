//
//  Sunrise&Sunset.swift
//  25
//
//  Created by Ruslan Gritsenko on 10/7/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import CoreLocation

final class Daytime {
    
    private let userDefaults = UserDefaults.standard
    private let calendar = Calendar.current
    private let secondsFromGMT = TimeZone.autoupdatingCurrent.secondsFromGMT()
    
    var sunriseTime: Date? {
        set {
            userDefaults.set(newValue, forKey: UserDefaults.Key.Sunrise)
        }
        get {
            return userDefaults.value(forKey: UserDefaults.Key.Sunrise) as? Date
        }
    }
    
    var sunsetTime: Date? {
        set {
            userDefaults.set(newValue, forKey: UserDefaults.Key.Sunset)
        }
        get {
            return userDefaults.value(forKey: UserDefaults.Key.Sunset) as? Date
        }
    }
    
    var isDay: Bool? {
        if let sunrise = self.sunriseTime, let sunset = self.sunsetTime {
            let currentTime = calendar.date(byAdding: .second, value: secondsFromGMT, to: Date())!
            return currentTime > sunrise && currentTime < sunset
        } else {
            return nil
        }
    }
    
    // MARK: - Initialization
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userLocationDidUpdate(_:)),
            name: Notification.Name.UserLocationDidUpdate,
            object: nil
        )
    }
    
    // MARK: - Notifications
    
    @objc func userLocationDidUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let location = userInfo[Notification.UserInfoKey.UserLocation] as? CLLocationCoordinate2D {
            self.getSunTimeInfo(with: location)
        }
    }
    
    // MARK: - Sunrise/Sunset Time Info
    
    private func getSunTimeInfo(with location: CLLocationCoordinate2D) {
        guard let solar = Solar(coordinate: location) else { return }
        let sunriseTime = calendar.date(byAdding: .second, value: secondsFromGMT, to: solar.sunrise!)!
        let sunsetTime = calendar.date(byAdding: .second, value: secondsFromGMT, to: solar.sunset!)!
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
    }
    
}
