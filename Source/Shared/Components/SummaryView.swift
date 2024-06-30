import Models
import SwiftUI

public struct SummaryView: View {
    public let summary: Summary?

    public init(summary: Summary? = nil) {
        self.summary = summary
    }

    public var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading) {
                Divider()
                    .padding(.bottom, 3)
                HStack(alignment: .center) {
                    if let totalCheckIns = summary?.totalCheckIns, let rating = summary?.averageRating {
                        RatingSummaryItem(title: "checkIn.segment.everyone", count: totalCheckIns, rating: rating)
                    }
                    if let friendsTotalCheckIns = summary?.friendsTotalCheckIns, let friendsAverageRating = summary?.friendsAverageRating {
                        SummaryDivider()
                        RatingSummaryItem(title: "checkIn.segment.friends", count: friendsTotalCheckIns, rating: friendsAverageRating)
                    }
                    if let currentUserTotalCheckIns = summary?.currentUserTotalCheckIns, let currentUserAverageRating = summary?.currentUserAverageRating {
                        SummaryDivider()
                        RatingSummaryItem(
                            title: "checkIn.segment.you",
                            count: currentUserTotalCheckIns,
                            rating: currentUserAverageRating
                        )
                    }
                    Spacer()
                }
                .frame(minWidth: UIScreen.main.bounds.width)
            }
        }
        .contentMargins(.leading, 16)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 12, trailing: 0))
    }
}

struct SummaryDivider: View {
    var body: some View {
        Divider()
            .frame(height: 50)
            .padding(.horizontal, 8)
    }
}

struct RatingSummaryItem: View {
    let title: LocalizedStringKey
    let count: Int?
    let rating: Double?

    var formattedRating: String {
        rating?.formatted(.number.precision(.fractionLength(1))) ?? "-"
    }

    var body: some View {
        SummaryItem(title: title, content: {
            Text(formattedRating)
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
        }, subContent: {
            RatingView(rating: rating ?? 0)
                .ratingSize(.small)
                .ratingColor(.gray)
        })
    }
}

struct SummaryItem<Content: View, SubContent: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder var content: () -> Content
    @ViewBuilder var subContent: () -> SubContent

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.gray.secondary)
                .textCase(.uppercase)
            Spacer().frame(height: 0)
            content()
            subContent()
        }
    }
}
