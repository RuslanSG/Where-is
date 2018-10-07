//
//  LocationManager.swift
//  25
//
//  Created by Ruslan Gritsenko on 10/7/18.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()

    // MARK: - Initialization
    
    override init() {
        super.init()
        
        getUserLocation()
    }
    
    // MARK: - Location
    
    private var currentLocation: CLLocationCoordinate2D? = nil {
        didSet {
            if currentLocation != nil {
                NotificationCenter.default.post(
                    name: Notification.Name.UserLocationDidUpdate,
                    object: nil,
                    userInfo: [Notification.UserInfoKey.UserLocation : currentLocation!]
                )
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
