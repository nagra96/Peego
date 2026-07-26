//
//  Models.swift
//  Peego
//

import Foundation
import CoreLocation

enum Amenity: String, Codable, CaseIterable, Identifiable {
    case clean
    case wheelchairAccessible
    case babyChangeTable
    case genderNeutral
    case freeToUse
    case familyFriendly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clean: "Clean"
        case .wheelchairAccessible: "Wheelchair Accessible"
        case .babyChangeTable: "Baby Change Table"
        case .genderNeutral: "Gender Neutral"
        case .freeToUse: "Free to Use"
        case .familyFriendly: "Family Friendly"
        }
    }

    var shortTitle: String {
        switch self {
        case .clean: "Clean"
        case .wheelchairAccessible: "Accessible"
        case .babyChangeTable: "Baby Change"
        case .genderNeutral: "Gender Neutral"
        case .freeToUse: "Free to Use"
        case .familyFriendly: "Family Friendly"
        }
    }

    var systemImage: String {
        switch self {
        case .clean: "sparkles"
        case .wheelchairAccessible: "figure.roll"
        case .babyChangeTable: "figure.and.child.holdinghands"
        case .genderNeutral: "person.2"
        case .freeToUse: "checkmark.seal"
        case .familyFriendly: "figure.2.and.child.holdinghands"
        }
    }

    /// Amenities offered as filters (matches the Filter screen).
    static let filterable: [Amenity] = [
        .wheelchairAccessible, .babyChangeTable, .genderNeutral, .freeToUse, .familyFriendly,
    ]
}

struct Washroom: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var isOpen: Bool
    var closingTime: String
    var about: String
    var amenities: [Amenity]
    /// Seeded community rating shown alongside user reviews.
    var seedRating: Double
    var seedCount: Int
    /// Seeded star breakdown, counts for [5, 4, 3, 2, 1] stars. Sums to seedCount.
    var seedBreakdown: [Int]
    var isUserAdded: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

struct Review: Identifiable, Codable, Hashable {
    var id: UUID
    var washroomID: UUID
    var author: String
    var rating: Int
    var text: String
    var date: Date
    var isUserAuthored: Bool
}

struct FilterSettings: Equatable {
    var amenities: Set<Amenity> = []
    var maxDistanceKM: Double = 5

    var isActive: Bool { !amenities.isEmpty || maxDistanceKM < 5 }
}
