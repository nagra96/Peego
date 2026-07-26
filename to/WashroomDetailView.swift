//
//  WashroomDetailView.swift
//  Peego
//

import SwiftUI
import MapKit

struct WashroomDetailView: View {
    @EnvironmentObject private var store: WashroomStore
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

    private func openDirections() {
        let placemark = MKPlacemark(coordinate: washroom.coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = washroom.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
        ])
    }
}

#Preview {
    NavigationStack {
        WashroomDetailView(washroom: SampleData.washrooms[0])
    }
    .environmentObject(WashroomStore())
}
