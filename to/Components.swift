//
//  Components.swift
//  Peego
//
//  Shared building blocks: logo, stars, chips, rows.
//

import SwiftUI

// MARK: - Logo

/// The Peego mark: a gradient location pin with a heart inside.
struct LogoView: View {
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Image(systemName: "drop.fill")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(180))
                .foregroundStyle(Theme.brandGradient)
            Circle()
                .fill(.white)
                .frame(width: size * 0.52, height: size * 0.52)
                .offset(y: -size * 0.10)
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.28, height: size * 0.28)
                .foregroundStyle(Theme.brandGradient)
                .offset(y: -size * 0.10)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Peego logo")
    }
}

struct WordmarkView: View {
    var fontSize: CGFloat = 44

    var body: some View {
        Text("peego")
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.brandGradient)
    }
}

// MARK: - Stars

struct StarRatingView: View {
    let rating: Double
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: symbol(for: star))
                    .font(.system(size: size))
                    .foregroundStyle(Theme.starYellow)
            }
        }
        .accessibilityLabel("\(rating, specifier: "%.1f") out of 5 stars")
    }

    private func symbol(for star: Int) -> String {
        if rating >= Double(star) - 0.25 { return "star.fill" }
        if rating >= Double(star) - 0.75 { return "star.leadinghalf.filled" }
        return "star"
    }
}

struct StarPickerView: View {
    @Binding var rating: Int
    var size: CGFloat = 32

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    rating = star
                } label: {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: size))
                        .foregroundStyle(star <= rating ? Theme.starYellow : Color.secondary.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityLabel("Your rating: \(rating) of 5 stars")
    }
}

// MARK: - Chips

struct AmenityChip: View {
    let amenity: Amenity
    var showsIcon = false

    var body: some View {
        HStack(spacing: 4) {
            if showsIcon {
                Image(systemName: amenity.systemImage)
                    .font(.caption2)
            }
            Text(amenity.shortTitle)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Theme.chipFill, in: Capsule())
        .foregroundStyle(Theme.deepPurple)
    }
}

struct AmenityChipRow: View {
    let amenities: [Amenity]
    var limit: Int = 3

    var body: some View {
        HStack(spacing: 6) {
            ForEach(amenities.prefix(limit)) { amenity in
                AmenityChip(amenity: amenity)
            }
        }
    }
}

// MARK: - Washroom row

struct WashroomRow: View {
    @EnvironmentObject private var store: WashroomStore
    let washroom: Washroom

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.chipFill)
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "toilet.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.purple)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(washroom.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(store.distanceText(for: washroom))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    StarRatingView(rating: store.averageRating(for: washroom), size: 10)
                    Text("(\(store.reviewCount(for: washroom)))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                store.toggleFavorite(washroom)
            } label: {
                Image(systemName: store.isFavorite(washroom) ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(store.isFavorite(washroom) ? Color.pink : Color.secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Status line

struct OpenStatusText: View {
    let washroom: Washroom

    var body: some View {
        HStack(spacing: 4) {
            Text(washroom.isOpen ? "Open" : "Closed")
                .fontWeight(.semibold)
                .foregroundStyle(washroom.isOpen ? Theme.openGreen : Color.red)
            Text("· Closes \(washroom.closingTime)")
                .foregroundStyle(.secondary)
        }
        .font(.caption)
    }
}
