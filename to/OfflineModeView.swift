//
//  OfflineModeView.swift
//  Peego
//

import SwiftUI

struct OfflineModeView: View {
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                ZStack {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 110))
                        .foregroundStyle(Theme.chipFill)
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.brandGradient)
                        .offset(y: 8)
                }

                Text("You're in Offline Mode")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Some features may be limited.\nWe'll show cached washrooms near you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                Button("Got it") {
                    onDismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OfflineModeView {}
}
