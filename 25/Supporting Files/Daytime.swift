//
//  Sunrise&Sunset.swift
//  25
//
//  Created by Ruslan Gritsenko on 10/7/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import CoreLocation

final class Daytime: NSObject, CLLocationManagerDelegate {
    
    private let userDefaults = UserDefaults.standard
    private let calendar = Calendar.current
    private let locationManager = CLLocationManager()
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
    
    override init() {
        super.init()
        
        self.getUserLocation()
    }
    
    // MARK: - Sunrise/Sunset Time Info
    
    private func getSunTimeInfo(with location: CLLocationCoordinate2D) {
        guard let solar = Solar(coordinate: location) else { return }
        let sunriseTime = calendar.date(byAdding: .second, value: secondsFromGMT, to: solar.sunrise!)!
        let sunsetTime = calendar.date(byAdding: .second, value: secondsFromGMT, to: solar.sunset!)!
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
    }
    
    // MARK: - Location
    
    private var currentLocation: CLLocationCoordinate2D? = nil {
        didSet {
            if currentLocation != nil {
                getSunTimeInfo(with: currentLocation!)
            }
        }
    }
    
    private func getUserLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            self.locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation == nil {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            currentLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
