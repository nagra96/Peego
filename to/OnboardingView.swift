//
//  OnboardingView.swift
//  Peego
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("peego.hasOnboarded") private var hasOnboarded = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                LogoView(size: 130)
                    .padding(.bottom, 18)

                WordmarkView(fontSize: 46)

                Text("Find Washrooms.\nFeel at Ease.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.top, 14)

                Spacer()

                Button("Get Started") {
                    hasOnboarded = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)

                Button("Skip") {
                    hasOnboarded = true
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
