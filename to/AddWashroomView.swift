//
//  AddWashroomView.swift
//  Peego
//

import SwiftUI
import MapKit
import PhotosUI
import UIKit

struct AddWashroomView: View {
    @EnvironmentObject private var store: WashroomStore

    @State private var placeName = ""
    @State private var pickedCoordinate: CLLocationCoordinate2D?
    @State private var amenities: Set<Amenity> = []
    @State private var rating = 0
    @State private var photoItem: PhotosPickerItem?
    @State private var photoImage: Image?
    @State private var showSubmitted = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    field(title: "Place Name") {
                        TextField("Enter place name", text: $placeName)
                            .padding(12)
                            .background(Theme.card, in: RoundedRectangle(cornerRadius: 12))
                    }

                    field(title: "Location") {
                        locationPicker
                    }

                    field(title: "Amenities") {
                        amenityGrid
                    }

                    field(title: "Your Rating") {
                        StarPickerView(rating: $rating, size: 28)
                    }

                    field(title: "Add Photos (optional)") {
                        photoPicker
                    }

                    Button("Submit") {
                        submit()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.5)
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("Add a Washroom")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Thank you! 💜", isPresented: $showSubmitted) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your washroom was added and will help other moms nearby.")
            }
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        photoImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }

    private var canSubmit: Bool {
        !placeName.trimmingCharacters(in: .whitespaces).isEmpty && pickedCoordinate != nil
    }

    private func field(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            content()
        }
    }

    private var locationPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            MapReader { proxy in
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: store.userLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    )
                )) {
                    if let coordinate = pickedCoordinate {
                        Marker("New washroom", systemImage: "toilet.fill", coordinate: coordinate)
                            .tint(Theme.purple)
                    }
                }
                .onTapGesture { screenPoint in
                    if let coordinate = proxy.convert(screenPoint, from: .local) {
                        pickedCoordinate = coordinate
                    }
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(pickedCoordinate == nil
                 ? "Tap the map to select the location"
                 : "Location selected ✓")
                .font(.caption)
                .foregroundStyle(pickedCoordinate == nil ? .secondary : Theme.openGreen)
        }
    }

    private var amenityGrid: some View {
        FlowChips(
            all: [.wheelchairAccessible, .babyChangeTable, .genderNeutral, .freeToUse, .familyFriendly, .clean],
            selected: $amenities
        )
    }

    private var photoPicker: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            Group {
                if let photoImage {
                    photoImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 84, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.secondary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(width: 84, height: 84)
                        .overlay {
                            Image(systemName: "camera")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                }
            }
        }
    }

    private func submit() {
        guard let coordinate = pickedCoordinate else { return }
        _ = store.addWashroom(
            name: placeName.trimmingCharacters(in: .whitespaces),
            coordinate: coordinate,
            amenities: Array(amenities),
            rating: rating
        )
        placeName = ""
        pickedCoordinate = nil
        amenities = []
        rating = 0
        photoItem = nil
        photoImage = nil
        showSubmitted = true
    }
}

/// Wrapping rows of selectable amenity chips.
struct FlowChips: View {
    let all: [Amenity]
    @Binding var selected: Set<Amenity>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8, alignment: .leading)], alignment: .leading, spacing: 8) {
            ForEach(all) { amenity in
                Button {
                    if selected.contains(amenity) {
                        selected.remove(amenity)
                    } else {
                        selected.insert(amenity)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: amenity.systemImage)
                            .font(.caption2)
                        Text(amenity.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        selected.contains(amenity) ? AnyShapeStyle(Theme.purple) : AnyShapeStyle(Theme.chipFill),
                        in: Capsule()
                    )
                    .foregroundStyle(selected.contains(amenity) ? .white : Theme.deepPurple)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    AddWashroomView()
        .environmentObject(WashroomStore())
}
