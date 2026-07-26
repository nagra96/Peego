//
//  HomeView.swift
//  Peego
//
//  Nearby washrooms list.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: WashroomStore

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    header

                    ForEach(store.sortedByDistance) { washroom in
                        NavigationLink(value: washroom) {
                            WashroomRow(washroom: washroom)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Theme.background)
            .navigationTitle("Nearby Washrooms")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Washroom.self) { washroom in
                WashroomDetailView(washroom: washroom)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            LogoView(size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("Find clean, safe and accessible washrooms")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("wherever you are 💜")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
        .padding(.top, 8)
    }
}

#Preview {
    HomeView()
        .environmentObject(WashroomStore())
}
