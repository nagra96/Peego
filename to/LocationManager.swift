//
//  LocationManager.swift
//  Peego
//
//  Wraps CLLocationManager and publishes the user's position.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    private let manager = CLLocationManager()

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    /// Asks for permission the first time, and resumes updates afterwards.
    func requestPermission() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    fileprivate func startIfAuthorized() {
        guard isAuthorized else { return }
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    // Delegate callbacks arrive off the main actor. Only Sendable values are
    // carried across the hop — the manager and CLLocation stay behind.
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        let latitude = latest.coordinate.latitude
        let longitude = latest.coordinate.longitude
        Task { @MainActor [weak self] in
            self?.currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            self?.authorizationStatus = status
            self?.startIfAuthorized()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Keep the last known fix; the map falls back to the default region.
    }
}
