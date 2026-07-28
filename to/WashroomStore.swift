//
//  WashroomStore.swift
//  Peego
//

import Foundation
import Combine
import CoreLocation
import Dispatch
import Network
import SwiftUI

@MainActor
final class WashroomStore: ObservableObject {
    @Published var washrooms: [Washroom]
    @Published var reviews: [Review]
    @Published var favoriteIDs: Set<UUID>
    @Published var filter = FilterSettings()
    @Published var searchText = ""
    @Published var currentLocation: CLLocation?

    let locationManager = LocationManager()

    /// Used until the first real fix arrives (and in the simulator with no
    /// location set), so distances are never blank.
    private let fallbackLocation = CLLocation(latitude: 49.2827, longitude: -123.1207)

    /// The user's real position when available, otherwise the fallback.
    var userLocation: CLLocation { currentLocation ?? fallbackLocation }

    var isUsingRealLocation: Bool { currentLocation != nil }

    private static let favoritesKey = "peego.favorites"
    private static let userWashroomsKey = "peego.userWashrooms"
    private static let userReviewsKey = "peego.userReviews"

    init() {
        let defaults = UserDefaults.standard
        var allWashrooms = SampleData.washrooms
        var allReviews = SampleData.reviews

        if let data = defaults.data(forKey: Self.userWashroomsKey),
           let saved = try? JSONDecoder().decode([Washroom].self, from: data) {
            allWashrooms.append(contentsOf: saved)
        }
        if let data = defaults.data(forKey: Self.userReviewsKey),
           let saved = try? JSONDecoder().decode([Review].self, from: data) {
            allReviews.append(contentsOf: saved)
        }
        washrooms = allWashrooms
        reviews = allReviews

        if let data = defaults.data(forKey: Self.favoritesKey),
           let saved = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            favoriteIDs = saved
        } else {
            favoriteIDs = [SampleData.timHortonsID, SampleData.walmartID]
        }

        // Mirror the manager's fixes onto the store so distance-sorted views
        // refresh as the user moves. assign(to:) captures no self.
        locationManager.$currentLocation.assign(to: &$currentLocation)
    }

    func requestLocationPermission() {
        locationManager.requestPermission()
    }

    // MARK: - Derived data

    func distanceKM(to washroom: Washroom) -> Double {
        userLocation.distance(from: washroom.location) / 1000
    }

    func distanceText(for washroom: Washroom) -> String {
        String(format: "%.1f km", distanceKM(to: washroom))
    }

    func reviews(for washroom: Washroom) -> [Review] {
        reviews
            .filter { $0.washroomID == washroom.id }
            .sorted { $0.date > $1.date }
    }

    func averageRating(for washroom: Washroom) -> Double {
        let userReviews = reviews.filter { $0.washroomID == washroom.id && $0.isUserAuthored }
        let totalStars = washroom.seedRating * Double(washroom.seedCount)
            + Double(userReviews.reduce(0) { $0 + $1.rating })
        let count = washroom.seedCount + userReviews.count
        guard count > 0 else { return 0 }
        return totalStars / Double(count)
    }

    func reviewCount(for washroom: Washroom) -> Int {
        washroom.seedCount + reviews.filter { $0.washroomID == washroom.id && $0.isUserAuthored }.count
    }

    /// Star breakdown as counts for [5, 4, 3, 2, 1] stars.
    func ratingBreakdown(for washroom: Washroom) -> [Int] {
        var counts = washroom.seedBreakdown.count == 5 ? washroom.seedBreakdown : [0, 0, 0, 0, 0]
        for review in reviews where review.washroomID == washroom.id && review.isUserAuthored {
            let index = 5 - min(max(review.rating, 1), 5)
            counts[index] += 1
        }
        return counts
    }

    var sortedByDistance: [Washroom] {
        washrooms.sorted { distanceKM(to: $0) < distanceKM(to: $1) }
    }

    /// Washrooms matching the active filter settings, nearest first. Search text
    /// deliberately does not narrow this — searching moves the map instead, so
    /// pins stay visible in whatever area you land on.
    var filteredWashrooms: [Washroom] {
        sortedByDistance.filter { washroom in
            if distanceKM(to: washroom) > filter.maxDistanceKM { return false }
            return filter.amenities.allSatisfy { washroom.amenities.contains($0) }
        }
    }

    var favorites: [Washroom] {
        sortedByDistance.filter { favoriteIDs.contains($0.id) }
    }

    var myReviews: [Review] {
        reviews.filter(\.isUserAuthored).sorted { $0.date > $1.date }
    }

    var myAddedPlaces: [Washroom] {
        washrooms.filter(\.isUserAdded)
    }

    func washroom(id: UUID) -> Washroom? {
        washrooms.first { $0.id == id }
    }

    /// A saved washroom whose name matches the query, so searching a known
    /// place jumps straight to it instead of round-tripping to MapKit.
    func firstWashroomMatching(_ query: String) -> Washroom? {
        sortedByDistance.first { $0.name.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Mutations

    func isFavorite(_ washroom: Washroom) -> Bool {
        favoriteIDs.contains(washroom.id)
    }

    func toggleFavorite(_ washroom: Washroom) {
        if favoriteIDs.contains(washroom.id) {
            favoriteIDs.remove(washroom.id)
        } else {
            favoriteIDs.insert(washroom.id)
        }
        persist()
    }

    func addReview(to washroom: Washroom, rating: Int, text: String) {
        let review = Review(
            id: UUID(),
            washroomID: washroom.id,
            author: "You",
            rating: rating,
            text: text,
            date: Date(),
            isUserAuthored: true
        )
        reviews.append(review)
        persist()
    }

    func addWashroom(
        name: String,
        coordinate: CLLocationCoordinate2D,
        amenities: [Amenity],
        rating: Int?
    ) -> Washroom {
        let washroom = Washroom(
            id: UUID(),
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            isOpen: true,
            closingTime: "10:00 PM",
            about: "Added by the Peego community.",
            amenities: amenities,
            seedRating: 0,
            seedCount: 0,
            seedBreakdown: [0, 0, 0, 0, 0],
            isUserAdded: true
        )
        washrooms.append(washroom)
        if let rating, rating > 0 {
            addReview(to: washroom, rating: rating, text: "Rated when adding this place.")
        }
        persist()
        return washroom
    }

    private func persist() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(favoriteIDs) {
            defaults.set(data, forKey: Self.favoritesKey)
        }
        if let data = try? encoder.encode(washrooms.filter(\.isUserAdded)) {
            defaults.set(data, forKey: Self.userWashroomsKey)
        }
        if let data = try? encoder.encode(reviews.filter(\.isUserAuthored)) {
            defaults.set(data, forKey: Self.userReviewsKey)
        }
    }
}

/// Watches connectivity so the app can surface the offline screen.
@MainActor
final class NetworkMonitor: ObservableObject {
    @Published var isOnline = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "peego.network.monitor")

    init() {
        startMonitoring()
    }

    // Handler setup lives outside init: inside an initializer `self` is still a
    // var, and capturing a var in concurrently-executing code is an error in
    // the Swift 6 language mode.
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            Task { @MainActor in
                self?.isOnline = online
            }
        }
        monitor.start(queue: queue)
    }
}
