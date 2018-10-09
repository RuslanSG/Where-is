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
    
    // MARK: - Location
    
    private let locationManager = CLLocationManager()
    
    private var currentLocation: CLLocationCoordinate2D? = nil {
        didSet {
            guard (currentLocation != nil) else { return }
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                var cityName = "Нет инфорации о местоположении"
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                if let city = placeMark.subAdministrativeArea {
                    cityName = city
                }
                NotificationCenter.default.post(
                    name: Notification.Name.UserLocationDidUpdate,
                    object: nil,
                    userInfo: [Notification.UserInfoKey.UserLocation : self.currentLocation!,
                               Notification.UserInfoKey.CityName     : cityName]
                )
            }
        }
    }
    
    func getUserLocation() {
        self.currentLocation = nil
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
        } else {
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
