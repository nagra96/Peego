//
//  MapScreen.swift
//  Peego
//
//  "Find Washrooms" map with search, filters and a selected-place card.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

struct MapScreen: View {
    @EnvironmentObject private var store: WashroomStore

    // .userLocation follows the user once authorized — this is what makes the
    // blue dot track — and falls back to downtown Vancouver until then.
    @State private var position: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207),
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
        )
    )
    @State private var selectedID: UUID?
    @State private var showFilters = false
    @State private var isSearching = false
    @State private var searchMessage: String?
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                map

                VStack(spacing: 8) {
                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    if let searchMessage {
                        Text(searchMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.card, in: Capsule())
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
                    }

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
            .animation(.snappy, value: searchMessage)
            .onAppear { store.requestLocationPermission() }
            .onDisappear { searchTask?.cancel() }
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
            MapUserLocationButton()
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
                    .submitLabel(.search)
                    .onSubmit(runSearch)
                if isSearching {
                    ProgressView()
                        .controlSize(.small)
                } else if !store.searchText.isEmpty {
                    Button {
                        store.searchText = ""
                        searchMessage = nil
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

    // MARK: - Search

    private func runSearch() {
        let query = store.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchMessage = nil
            return
        }

        // A saved washroom wins: select it and centre on it, no network needed.
        if let match = store.firstWashroomMatching(query) {
            searchMessage = nil
            selectedID = match.id
            withAnimation {
                position = .region(region(around: match.coordinate, meters: 1_200))
            }
            return
        }

        searchTask?.cancel()
        isSearching = true
        searchMessage = nil
        searchTask = Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region(around: store.userLocation.coordinate, meters: 30_000)

            do {
                // boundingRegion covers the results without touching MKMapItem's
                // placemark, which is deprecated in iOS 26.
                let response = try await MKLocalSearch(request: request).start()
                guard !Task.isCancelled else { return }
                selectedID = nil
                withAnimation {
                    position = .region(response.boundingRegion)
                }
                searchMessage = "Showing washrooms near \(query)"
            } catch {
                guard !Task.isCancelled else { return }
                searchMessage = "No places found for \"\(query)\""
            }
            isSearching = false
        }
    }

    // MARK: - Regions

    private func region(around coordinate: CLLocationCoordinate2D, meters: CLLocationDistance) -> MKCoordinateRegion {
        MKCoordinateRegion(center: coordinate, latitudinalMeters: meters, longitudinalMeters: meters)
    }
}

#Preview {
    MapScreen()
        .environmentObject(WashroomStore())
}
