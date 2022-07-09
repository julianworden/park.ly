//
//  LocationController.swift
//  park.ly
//
//  Created by Julian Worden on 7/8/22.
//

import Foundation
import CoreLocation

protocol CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    static let instance = LocationService()

    var customUserLocationDelegate: CustomUserLocationDelegate?

    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = manager.location?.coordinate

        if let customUserLocationDelegate = customUserLocationDelegate {
            customUserLocationDelegate.userLocationUpdated(location: locations.first!)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            print("We have access already!")
        case .authorizedWhenInUse:
            print("We have access already!")
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
