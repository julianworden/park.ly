//
//  ParkingSpot.swift
//  park.ly
//
//  Created by Julian Worden on 7/8/22.
//

import Foundation
import MapKit

class ParkingSpot: NSObject, MKAnnotation {
    var title: String? = "We Parked Here"
    var subtitle: String? = "Tap for directions"
    var coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
