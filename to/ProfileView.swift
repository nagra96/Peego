//
//  ProfileView.swift
//  Peego
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: WashroomStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header

                    VStack(spacing: 0) {
                        NavigationLink {
                            MyReviewsView()
                        } label: {
                            menuRow(title: "My Reviews", systemImage: "star")
                        }
                        Divider().padding(.leading, 52)
                        NavigationLink {
                            MyAddedPlacesView()
                        } label: {
                            menuRow(title: "My Added Places", systemImage: "mappin.and.ellipse")
                        }
                        Divider().padding(.leading, 52)
                        NavigationLink {
                            SettingsView()
                        } label: {
                            menuRow(title: "Settings", systemImage: "gearshape")
                        }
                        Divider().padding(.leading, 52)
                        NavigationLink {
                            OfflineMapsView()
                        } label: {
                            menuRow(title: "Offline Maps", systemImage: "arrow.down.circle")
                        }
                    }
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))

                    VStack(spacing: 0) {
                        NavigationLink {
                            AboutView()
                        } label: {
                            menuRow(title: "About Peego", systemImage: "info.circle")
                        }
                        Divider().padding(.leading, 52)
                        HStack {
                            menuRow(title: "Version 1.0.0", systemImage: "number", showsChevron: false)
                        }
                    }
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Theme.brandGradient)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, Mom!")
                    .font(.headline)
                Text("You're doing great 💜")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
    }

    private func menuRow(title: String, systemImage: String, showsChevron: Bool = true) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundStyle(Theme.purple)
                .frame(width: 26)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Subpages

struct MyReviewsView: View {
    @EnvironmentObject private var store: WashroomStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if store.myReviews.isEmpty {
                    Text("You haven't written any reviews yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    ForEach(store.myReviews) { review in
                        VStack(alignment: .leading, spacing: 4) {
                            if let place = store.washroom(id: review.washroomID) {
                                Text(place.name)
                                    .font(.caption)
                                    .foregroundStyle(Theme.purple)
                            }
                            ReviewCard(review: review)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("My Reviews")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MyAddedPlacesView: View {
    @EnvironmentObject private var store: WashroomStore

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if store.myAddedPlaces.isEmpty {
                    Text("You haven't added any places yet. Use the Add tab to contribute one!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                } else {
                    ForEach(store.myAddedPlaces) { washroom in
                        NavigationLink(value: washroom) {
                            WashroomRow(washroom: washroom)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("My Added Places")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Washroom.self) { washroom in
            WashroomDetailView(washroom: washroom)
        }
    }
}

struct SettingsView: View {
    @AppStorage("peego.notifications") private var notifications = true
    @AppStorage("peego.units") private var useKilometres = true

    var body: some View {
        Form {
            Section("Preferences") {
                Toggle("Notifications", isOn: $notifications)
                    .tint(Theme.purple)
                Toggle("Use kilometres", isOn: $useKilometres)
                    .tint(Theme.purple)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OfflineMapsView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.purple)
            Text("Offline Maps")
                .font(.headline)
            Text("Washrooms near you are cached automatically so Peego keeps working when you lose signal.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .navigationTitle("Offline Maps")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 14) {
            LogoView(size: 90)
            WordmarkView(fontSize: 34)
            Text("Pregnant Washroom Finder")
                .font(.headline)
            Text("Find clean, safe and accessible washrooms — wherever you are.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .navigationTitle("About Peego")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .environmentObject(WashroomStore())
}
