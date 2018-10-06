//
//  AutomaticDarkMode.swift
//  25
//
//  Created by Ruslan Gritsenko on 22.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import CoreLocation

final class AutomaticDarkMode: NSObject, CLLocationManagerDelegate {

    private let userDefaults = UserDefaults.standard
    public let calendar = Calendar.current
    let locationManager = CLLocationManager()
    private lazy var appearance = Appearance()

    var isOn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: StringKeys.UserDefaultsKey.AutomaticDarkMode)
        }
        get {
            return UserDefaults.standard.bool(forKey: StringKeys.UserDefaultsKey.AutomaticDarkMode)
        }
    }
    
    public var sunrise: Date? {
        set {
            userDefaults.set(newValue, forKey: StringKeys.UserDefaultsKey.Sunrise)
        }
        get {
            return userDefaults.value(forKey: StringKeys.UserDefaultsKey.Sunrise) as? Date
        }
    }
    
    public var sunset: Date? {
        set {
            userDefaults.set(newValue, forKey: StringKeys.UserDefaultsKey.Sunset)
        }
        get {
            return userDefaults.value(forKey:  StringKeys.UserDefaultsKey.Sunset) as? Date
        }
    }
    
    public var isDay: Bool? {
        if let sunrise = self.sunrise, let sunset = self.sunset {
            let currentTime = calendar.date(byAdding: .hour, value: 3, to: Date())!
            return currentTime > sunrise && currentTime < sunset
        } else {
            return nil
        }
    }
    
    // MARK: - Initialization
    
    init(for appearance: Appearance) {
        super.init()
        self.appearance = appearance
    }
    
    // MARK: - Location
    
    var currentLocation: CLLocationCoordinate2D? = nil {
        didSet {
            if currentLocation != nil {
                getSunTimeInfo(with: currentLocation!)
                if isOn {
                    setDarkModeByCurrentTime()
                }
            }
        }
    }
    
    func getUserLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Sunrise/Sunset Time Info
    
    internal func getSunTimeInfo(with location: CLLocationCoordinate2D) {
        guard let solar = Solar(coordinate: location) else { return }
        let sunrise = calendar.date(byAdding: .hour, value: 3, to: solar.sunrise!)!
        let sunset = calendar.date(byAdding: .hour, value: 3, to: solar.sunset!)!
        self.sunrise = sunrise
        self.sunset = sunset
        
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            currentLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        }
    }
    
    // MARK: - Helping Methods
    
    func setDarkModeByCurrentTime() {
        if let isDay = isDay {
            appearance.darkMode = !isDay
        }
    }
    
}
