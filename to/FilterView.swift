//
//  FilterView.swift
//  Peego
//

import SwiftUI

struct FilterView: View {
    @EnvironmentObject private var store: WashroomStore
    @Environment(\.dismiss) private var dismiss

    @State private var amenities: Set<Amenity> = []
    @State private var maxDistance: Double = 5

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Amenities")
                                .font(.headline)
                            ForEach(Amenity.filterable) { amenity in
                                Toggle(isOn: binding(for: amenity)) {
                                    Label(amenity.title, systemImage: amenity.systemImage)
                                        .font(.subheadline)
                                }
                                .tint(Theme.purple)
                                .padding(.vertical, 6)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Distance")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.0f km", maxDistance))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $maxDistance, in: 1...5, step: 0.5)
                                .tint(Theme.purple)
                        }
                    }
                    .padding(20)
                }

                Button("Apply Filters") {
                    store.filter = FilterSettings(amenities: amenities, maxDistanceKM: maxDistance)
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Theme.background)
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        amenities = []
                        maxDistance = 5
                    }
                    .foregroundStyle(Theme.purple)
                }
            }
            .onAppear {
                amenities = store.filter.amenities
                maxDistance = store.filter.maxDistanceKM
            }
        }
    }

    private func binding(for amenity: Amenity) -> Binding<Bool> {
        Binding(
            get: { amenities.contains(amenity) },
            set: { isOn in
                if isOn {
                    amenities.insert(amenity)
                } else {
                    amenities.remove(amenity)
                }
            }
        )
    }
}

#Preview {
    FilterView()
        .environmentObject(WashroomStore())
}
