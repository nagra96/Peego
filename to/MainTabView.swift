//
//  MainTabView.swift
//  Peego
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var network: NetworkMonitor
    @State private var showOfflineNotice = false
    @State private var dismissedOfflineNotice = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            MapScreen()
                .tabItem { Label("Map", systemImage: "map") }

            AddWashroomView()
                .tabItem { Label("Add", systemImage: "plus.circle") }

            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "heart") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .tint(Theme.purple)
        .fullScreenCover(isPresented: $showOfflineNotice) {
            OfflineModeView {
                dismissedOfflineNotice = true
                showOfflineNotice = false
            }
        }
        .onChange(of: network.isOnline) { _, isOnline in
            if isOnline {
                dismissedOfflineNotice = false
                showOfflineNotice = false
            } else if !dismissedOfflineNotice {
                showOfflineNotice = true
            }
        }
    }
}

struct RootView: View {
    @AppStorage("peego.hasOnboarded") private var hasOnboarded = false
    @StateObject private var store = WashroomStore()
    @StateObject private var network = NetworkMonitor()

    var body: some View {
        Group {
            if hasOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .environmentObject(network)
    }
}

#Preview {
    RootView()
}
