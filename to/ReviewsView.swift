//
//  ReviewsView.swift
//  Peego
//

import Foundation
import SwiftUI

struct ReviewsView: View {
    @EnvironmentObject private var store: WashroomStore
    let washroom: Washroom

    @State private var showAddReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summary

                LazyVStack(spacing: 12) {
                    ForEach(store.reviews(for: washroom)) { review in
                        ReviewCard(review: review)
                    }
                }

                Button("Add Review") {
                    showAddReview = true
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddReview) {
            AddReviewView(washroom: washroom)
                .presentationDetents([.medium, .large])
        }
    }

    private var summary: some View {
        let breakdown = store.ratingBreakdown(for: washroom)
        let total = max(breakdown.reduce(0, +), 1)

        return HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.1f", store.averageRating(for: washroom)))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                StarRatingView(rating: store.averageRating(for: washroom))
                Text("(\(store.reviewCount(for: washroom)) reviews)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    HStack(spacing: 8) {
                        Text("\(5 - index)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 10)
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Theme.chipFill)
                                Capsule()
                                    .fill(Theme.starYellow)
                                    .frame(width: proxy.size.width * CGFloat(breakdown[index]) / CGFloat(total))
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Theme.brandGradient)
                    .frame(width: 34, height: 34)
                    .overlay {
                        Text(review.author.prefix(1))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                VStack(alignment: .leading, spacing: 1) {
                    Text(review.author)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(review.date, format: .relative(presentation: .named))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            StarRatingView(rating: Double(review.rating), size: 12)
            Text(review.text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct AddReviewView: View {
    @EnvironmentObject private var store: WashroomStore
    @Environment(\.dismiss) private var dismiss
    let washroom: Washroom

    @State private var rating = 0
    @State private var text = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("How was \(washroom.name)?")
                    .font(.headline)
                    .padding(.top, 12)

                StarPickerView(rating: $rating)

                TextField("Share your experience...", text: $text, axis: .vertical)
                    .lineLimit(4...8)
                    .padding(12)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 12))

                Button("Submit Review") {
                    store.addReview(to: washroom, rating: rating, text: text)
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(rating == 0)
                .opacity(rating == 0 ? 0.5 : 1)

                Spacer()
            }
            .padding(20)
            .background(Theme.background)
            .navigationTitle("Add Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.purple)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReviewsView(washroom: SampleData.washrooms[0])
    }
    .environmentObject(WashroomStore())
}
