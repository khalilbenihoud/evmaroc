//
//  LocationService.swift
//  EVMaroc
//
//  Gère la localisation GPS de l'utilisateur
//

import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }

    /// Demande la permission de localisation
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Demande une position unique
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        locationManager.requestLocation()
    }

    /// Position par défaut : Casablanca
    var defaultLocation: CLLocation {
        CLLocation(latitude: 33.5731, longitude: -7.5898)
    }

    /// Position à utiliser (réelle ou par défaut)
    var locationForDisplay: CLLocation {
        currentLocation ?? defaultLocation
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            requestLocation()
        }
    }
}
