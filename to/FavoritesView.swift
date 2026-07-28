//
//  FavoritesView.swift
//  Peego
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var store: WashroomStore

    var body: some View {
        NavigationStack {
            Group {
                if store.favorites.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(store.favorites) { washroom in
                                NavigationLink(value: washroom) {
                                    WashroomRow(washroom: washroom)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Theme.background)
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Washroom.self) { washroom in
                WashroomDetailView(washroom: washroom)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 44))
                .foregroundStyle(Theme.purple.opacity(0.5))
            Text("No favorites yet")
                .font(.headline)
            Text("Tap the heart on any washroom to save it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

#Preview {
    FavoritesView()
        .environmentObject(WashroomStore())
}
