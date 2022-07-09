//
//  ViewController+MapKit.swift
//  park.ly
//
//  Created by Julian Worden on 7/9/22.
//

import CoreLocation
import Foundation
import MapKit

// MARK: Setup MapKit

extension ViewController: MKMapViewDelegate {
    func checkLocationAuthorizationStatus() {
        switch locationService.locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.mapView.showsUserLocation = true
            locationService.customUserLocationDelegate = self
        default:
            locationService.locationManager.requestWhenInUseAuthorization()
        }
    }

    func centerMapOnUserLocation(coordinates: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }

    func setupAnnotation(coordinate: CLLocationCoordinate2D) {
        parkedCarAnnotation = ParkingSpot(coordinate: coordinate)
        mapView.addAnnotation(parkedCarAnnotation!)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingSpot {
            let id = "pin"
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = true
            view.animatesWhenAdded = true
            view.tintColor = .red
            view.calloutOffset = CGPoint(x: -8, y: -3)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }
        return nil
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        guard let parkedCarAnnotation = parkedCarAnnotation,
              let userCoordinates = locationService.currentLocation else { return }

        getDirectionsToCar(userCoordinates: userCoordinates, parkedCarCoordinates: parkedCarAnnotation.coordinate)
        view.setSelected(false, animated: true)
    }
}

// MARK: CustomUserLocationDelegate

extension ViewController: CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation) {
        centerMapOnUserLocation(coordinates: location.coordinate)
    }
}

// MARK: Gesture Setup

extension ViewController {
    func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPress.minimumPressDuration = 0.75
        mapView.addGestureRecognizer(longPress)
    }

    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)

        if gesture.state == .ended {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            setupAnnotation(coordinate: coordinate)

            directionsButton.isEnabled = true
            parkCarButton.setImage(UIImage(named: "foundCar"), for: .normal)
        }
    }
}

// MARK: Directions and Polyline Setup

extension ViewController {
    func getDirectionsToCar(userCoordinates: CLLocationCoordinate2D, parkedCarCoordinates: CLLocationCoordinate2D) {
        removeOverlays()

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinates))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: parkedCarCoordinates))
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, _ in
            guard let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50),
                animated: true
            )

            for step in route.steps {
                print(step.distance)
                print(step.instructions)
            }
        }
    }

    // swiftlint:disable force_cast
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let directionsRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        directionsRenderer.strokeColor = .systemBlue
        directionsRenderer.lineWidth = 5
        directionsRenderer.alpha = 0.85

        return directionsRenderer
    }

    func removeOverlays() {
        mapView.overlays.forEach({ self.mapView.removeOverlay($0) })
    }
}
