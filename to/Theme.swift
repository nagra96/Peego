//
//  Theme.swift
//  Peego
//
//  Brand colors and shared styling.
//

import SwiftUI
import UIKit

extension Color {
    /// Dynamic color that adapts to light/dark appearance.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

enum Theme {
    static let purple = Color(red: 0.545, green: 0.361, blue: 0.965)       // #8B5CF6
    static let deepPurple = Color(red: 0.486, green: 0.227, blue: 0.929)   // #7C3AED
    static let magenta = Color(red: 0.851, green: 0.275, blue: 0.937)      // #D946EF

    static let brandGradient = LinearGradient(
        colors: [magenta, deepPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Soft pink app background (dark-mode aware).
    static let background = Color(
        light: Color(red: 0.992, green: 0.957, blue: 0.980),
        dark: Color(red: 0.09, green: 0.07, blue: 0.12)
    )

    /// Card / elevated surface color.
    static let card = Color(
        light: .white,
        dark: Color(red: 0.16, green: 0.13, blue: 0.20)
    )

    /// Subtle chip fill.
    static let chipFill = Color(
        light: Color(red: 0.955, green: 0.94, blue: 0.99),
        dark: Color(red: 0.22, green: 0.18, blue: 0.28)
    )

    static let starYellow = Color(red: 0.98, green: 0.75, blue: 0.18)
    static let openGreen = Color(red: 0.13, green: 0.69, blue: 0.30)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.purple, in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Theme.purple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.chipFill, in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
