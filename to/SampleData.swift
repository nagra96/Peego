//
//  SampleData.swift
//  Peego
//
//  Seeded washrooms and reviews around downtown Vancouver, BC.
//

import Foundation

enum SampleData {
    static let timHortonsID = UUID(uuidString: "6A5C1F30-0001-4000-8000-000000000001")!
    static let walmartID = UUID(uuidString: "6A5C1F30-0001-4000-8000-000000000002")!
    static let starbucksID = UUID(uuidString: "6A5C1F30-0001-4000-8000-000000000003")!
    static let londonDrugsID = UUID(uuidString: "6A5C1F30-0001-4000-8000-000000000004")!
    static let libraryID = UUID(uuidString: "6A5C1F30-0001-4000-8000-000000000005")!
    static let communityCentreID = UUID(uuidString: "6A5C1F30-0001-4000-8000-000000000006")!

    static let washrooms: [Washroom] = [
        Washroom(
            id: timHortonsID,
            name: "Tim Hortons",
            latitude: 49.2840, longitude: -123.1185,
            isOpen: true, closingTime: "10:00 PM",
            about: "Clean and well maintained. Accessible entrance and baby change available.",
            amenities: [.clean, .wheelchairAccessible, .babyChangeTable, .genderNeutral, .freeToUse],
            seedRating: 4.6, seedCount: 32, seedBreakdown: [23, 6, 2, 1, 0],
            isUserAdded: false
        ),
        Washroom(
            id: walmartID,
            name: "Walmart Supercentre",
            latitude: 49.2770, longitude: -123.1300,
            isOpen: true, closingTime: "11:00 PM",
            about: "Large family washroom near the customer service desk. Stroller friendly aisles.",
            amenities: [.wheelchairAccessible, .babyChangeTable, .familyFriendly, .freeToUse],
            seedRating: 4.2, seedCount: 21, seedBreakdown: [11, 6, 3, 1, 0],
            isUserAdded: false
        ),
        Washroom(
            id: starbucksID,
            name: "Starbucks",
            latitude: 49.2905, longitude: -123.1250,
            isOpen: true, closingTime: "9:00 PM",
            about: "Single-stall gender neutral washroom. Usually clean, can be busy at peak hours.",
            amenities: [.clean, .genderNeutral, .freeToUse],
            seedRating: 4.0, seedCount: 14, seedBreakdown: [6, 4, 3, 1, 0],
            isUserAdded: false
        ),
        Washroom(
            id: londonDrugsID,
            name: "London Drugs",
            latitude: 49.2790, longitude: -123.1090,
            isOpen: false, closingTime: "8:00 PM",
            about: "Accessible washroom at the back of the store. Ask staff for the key after 6 PM.",
            amenities: [.wheelchairAccessible, .freeToUse],
            seedRating: 3.8, seedCount: 9, seedBreakdown: [3, 3, 2, 0, 1],
            isUserAdded: false
        ),
        Washroom(
            id: libraryID,
            name: "Central Public Library",
            latitude: 49.2797, longitude: -123.1152,
            isOpen: true, closingTime: "9:00 PM",
            about: "Spacious public washrooms on every floor with baby change tables and low-traffic quiet hours.",
            amenities: [.clean, .wheelchairAccessible, .babyChangeTable, .genderNeutral, .freeToUse, .familyFriendly],
            seedRating: 4.8, seedCount: 41, seedBreakdown: [34, 6, 1, 0, 0],
            isUserAdded: false
        ),
        Washroom(
            id: communityCentreID,
            name: "Roundhouse Community Centre",
            latitude: 49.2726, longitude: -123.1216,
            isOpen: true, closingTime: "10:00 PM",
            about: "Family washroom with change table and nursing-friendly seating nearby.",
            amenities: [.clean, .babyChangeTable, .familyFriendly, .freeToUse],
            seedRating: 4.5, seedCount: 18, seedBreakdown: [12, 4, 1, 1, 0],
            isUserAdded: false
        ),
    ]

    static let reviews: [Review] = [
        Review(
            id: UUID(uuidString: "6A5C1F30-0002-4000-8000-000000000001")!,
            washroomID: timHortonsID, author: "Sarah K.", rating: 5,
            text: "Very clean and has baby change table. Life saver!",
            date: Date().addingTimeInterval(-2 * 86_400), isUserAuthored: false
        ),
        Review(
            id: UUID(uuidString: "6A5C1F30-0002-4000-8000-000000000002")!,
            washroomID: timHortonsID, author: "Amandeep K.", rating: 4,
            text: "Accessible entrance and spacious.",
            date: Date().addingTimeInterval(-7 * 86_400), isUserAuthored: false
        ),
        Review(
            id: UUID(uuidString: "6A5C1F30-0002-4000-8000-000000000003")!,
            washroomID: timHortonsID, author: "Priya M.", rating: 5,
            text: "Staff were kind and it was spotless. Highly recommend when you're out and about.",
            date: Date().addingTimeInterval(-12 * 86_400), isUserAuthored: false
        ),
        Review(
            id: UUID(uuidString: "6A5C1F30-0002-4000-8000-000000000004")!,
            washroomID: walmartID, author: "Jessica T.", rating: 4,
            text: "Family washroom was easy to find and had plenty of room for the stroller.",
            date: Date().addingTimeInterval(-3 * 86_400), isUserAuthored: false
        ),
        Review(
            id: UUID(uuidString: "6A5C1F30-0002-4000-8000-000000000005")!,
            washroomID: starbucksID, author: "Monica L.", rating: 4,
            text: "Clean single stall. There can be a short wait in the mornings.",
            date: Date().addingTimeInterval(-5 * 86_400), isUserAuthored: false
        ),
        Review(
            id: UUID(uuidString: "6A5C1F30-0002-4000-8000-000000000006")!,
            washroomID: libraryID, author: "Harleen S.", rating: 5,
            text: "The quietest, cleanest option downtown. Change tables on every floor!",
            date: Date().addingTimeInterval(-1 * 86_400), isUserAuthored: false
        ),
        Review(
            id: UUID(uuidString: "6A5C1F30-0002-4000-8000-000000000007")!,
            washroomID: londonDrugsID, author: "Emily R.", rating: 3,
            text: "Fine in a pinch, but you need to ask for the key in the evening.",
            date: Date().addingTimeInterval(-9 * 86_400), isUserAuthored: false
        ),
    ]
}
