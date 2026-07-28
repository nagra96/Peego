//
//  WashroomDetailView.swift
//  Peego
//

import Foundation
import CoreLocation
import SwiftUI

struct WashroomDetailView: View {
    @EnvironmentObject private var store: WashroomStore
    @Environment(\.openURL) private var openURL
    let washroom: Washroom

    @State private var showAddReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                HStack(spacing: 6) {
                    ForEach(washroom.amenities.prefix(3)) { amenity in
                        AmenityChip(amenity: amenity)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("About this washroom")
                        .font(.headline)
                    Text(washroom.about)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Amenities")
                        .font(.headline)
                    ForEach(washroom.amenities) { amenity in
                        Label(amenity.title, systemImage: amenity.systemImage)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }

                VStack(spacing: 10) {
                    Button("Directions") {
                        openDirections()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Add Review") {
                        showAddReview = true
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle(washroom.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleFavorite(washroom)
                } label: {
                    Image(systemName: store.isFavorite(washroom) ? "heart.fill" : "heart")
                        .foregroundStyle(store.isFavorite(washroom) ? Color.pink : Theme.purple)
                }
            }
        }
        .sheet(isPresented: $showAddReview) {
            AddReviewView(washroom: washroom)
                .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(washroom.name)
                .font(.title2)
                .fontWeight(.bold)
            Text("\(store.distanceText(for: washroom)) away")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            OpenStatusText(washroom: washroom)
            NavigationLink {
                ReviewsView(washroom: washroom)
            } label: {
                HStack(spacing: 6) {
                    StarRatingView(rating: store.averageRating(for: washroom))
                    Text(String(format: "%.1f", store.averageRating(for: washroom)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text("(\(store.reviewCount(for: washroom)) reviews)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // Built as a Maps URL rather than an MKMapItem: MKPlacemark and
    // MKMapItem(placemark:) are both deprecated in iOS 26, and their
    // replacements are iOS 26-only, so either branch of an availability check
    // would warn on this deployment target. The URL scheme is stable on all of
    // them.
    private func openDirections() {
        let coordinate = washroom.coordinate
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "q", value: washroom.name),
            URLQueryItem(name: "dirflg", value: "w"),
        ]
        if let url = components?.url {
            openURL(url)
        }
    }
}

#Preview {
    NavigationStack {
        WashroomDetailView(washroom: SampleData.washrooms[0])
    }
    .environmentObject(WashroomStore())
}
