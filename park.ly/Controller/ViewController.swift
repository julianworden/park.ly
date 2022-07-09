//
//  ViewController.swift
//  park.ly
//
//  Created by Julian Worden on 7/7/22.
//

import CoreLocation
import MapKit
import UIKit

// MARK: View and Button Selectors Setup
class ViewController: UIViewController {

    private lazy var buttonStack = UIStackView(arrangedSubviews: [locationButton, parkCarButton, directionsButton])
    var mapView = MKMapView()
    private var logoImageView = UIImageView()
    var locationButton = RoundButton(
        image: UIImage(systemName: "location")!,
        cornerRadius: 25,
        backgroundColor: .white
    )
    var parkCarButton = RoundButton(
        image: UIImage(named: "parkCar")!,
        cornerRadius: 37.5,
        backgroundColor: .white
    )
    var directionsButton = RoundButton(
        image: UIImage(systemName: "car")!,
        cornerRadius: 25,
        backgroundColor: .white
    )

    var locationService = LocationService.instance

    var parkedCarAnnotation: ParkingSpot?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        configureViews()
        layoutViews()
        checkLocationAuthorizationStatus()
        setupLongPress()
    }

    func configureViews() {
        mapView.delegate = self

        logoImageView.image = UIImage(named: "park.ly-logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true

        buttonStack.axis = .horizontal
        buttonStack.distribution = .fill
        buttonStack.alignment = .center
        buttonStack.spacing = 10

        locationButton.addTarget(self, action: #selector(resetMapCenter), for: .touchUpInside)
        parkCarButton.addTarget(self, action: #selector(parkButtonTapped), for: .touchUpInside)
        directionsButton.addTarget(self, action: #selector(getDirectionsTapped), for: .touchUpInside)

        directionsButton.isEnabled = false
    }

    func layoutViews() {
        view.addSubview(mapView)
        view.addSubview(logoImageView)
        view.addSubview(buttonStack)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        parkCarButton.translatesAutoresizingMaskIntoConstraints = false
        directionsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoImageView.heightAnchor.constraint(equalToConstant: 128),

            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            locationButton.heightAnchor.constraint(equalToConstant: 50),
            locationButton.widthAnchor.constraint(equalToConstant: 50),

            parkCarButton.heightAnchor.constraint(equalToConstant: 75),
            parkCarButton.widthAnchor.constraint(equalToConstant: 75),

            directionsButton.heightAnchor.constraint(equalToConstant: 50),
            directionsButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func resetMapCenter() {
        guard let coordinates = locationService.currentLocation else { return }
        centerMapOnUserLocation(coordinates: coordinates)
    }

    @objc func parkButtonTapped() {
        removeOverlays()
        mapView.removeAnnotations(mapView.annotations)
        guard let coordinates = locationService.currentLocation else { return }

        if parkedCarAnnotation == nil {
            setupAnnotation(coordinate: coordinates)
            parkCarButton.setImage(UIImage(named: "foundCar"), for: .normal)
            directionsButton.isEnabled = true
        } else {
            parkCarButton.setImage(UIImage(named: "parkCar"), for: .normal)
            parkedCarAnnotation = nil
            directionsButton.isEnabled = false
            centerMapOnUserLocation(coordinates: coordinates)
        }
    }

    @objc func getDirectionsTapped() {
        guard let userCoordinates = locationService.currentLocation,
              let parkedCarAnnotation = parkedCarAnnotation else { return }

        getDirectionsToCar(userCoordinates: userCoordinates, parkedCarCoordinates: parkedCarAnnotation.coordinate)
    }
}
