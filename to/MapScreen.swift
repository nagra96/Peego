//
//  MapScreen.swift
//  Peego
//
//  "Find Washrooms" map with search, filters and a selected-place card.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    @EnvironmentObject private var store: WashroomStore

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    @State private var selectedID: UUID?
    @State private var showFilters = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                map

                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    Spacer()

                    if let selected = selectedID.flatMap(store.washroom(id:)) {
                        selectedCard(for: selected)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Find Washrooms")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilters) {
                FilterView()
                    .presentationDetents([.large])
            }
            .navigationDestination(for: Washroom.self) { washroom in
                WashroomDetailView(washroom: washroom)
            }
            .animation(.snappy, value: selectedID)
        }
    }

    private var map: some View {
        Map(position: $position, selection: $selectedID) {
            UserAnnotation()

            ForEach(store.filteredWashrooms) { washroom in
                Marker(washroom.name, systemImage: "toilet.fill", coordinate: washroom.coordinate)
                    .tint(Theme.purple)
                    .tag(washroom.id)
            }
        }
        .mapControls {
            MapCompass()
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search location...", text: $store.searchText)
                    .autocorrectionDisabled()
                if !store.searchText.isEmpty {
                    Button {
                        store.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 12))

            Button {
                showFilters = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(store.filter.isActive ? .white : Theme.purple)
                    .padding(10)
                    .background(
                        store.filter.isActive ? AnyShapeStyle(Theme.purple) : AnyShapeStyle(Theme.card),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
    }

    private func selectedCard(for washroom: Washroom) -> some View {
        NavigationLink(value: washroom) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(washroom.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.turn.up.right")
                        .foregroundStyle(Theme.purple)
                }
                HStack(spacing: 6) {
                    Text(store.distanceText(for: washroom))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    OpenStatusText(washroom: washroom)
                }
                HStack(spacing: 4) {
                    StarRatingView(rating: store.averageRating(for: washroom), size: 12)
                    Text("(\(store.reviewCount(for: washroom)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                AmenityChipRow(amenities: washroom.amenities)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MapScreen()
        .environmentObject(WashroomStore())
}
