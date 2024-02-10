import Models
import SwiftUI

public struct SummaryView: View {
    public let summary: Summary?

    public init(summary: Summary? = nil) {
        self.summary = summary
    }

    public var body: some View {
        Grid(alignment: .leading) {
            header
            Divider().gridCellUnsizedAxes(.horizontal)
            SummaryRow(title: "checkIn.segment.everyone", count: summary?.totalCheckIns, rating: summary?.averageRating)
            Divider().gridCellUnsizedAxes(.horizontal)
            SummaryRow(title: "checkIn.segment.friends", count: summary?.friendsTotalCheckIns, rating: summary?.friendsAverageRating)
            Divider().gridCellUnsizedAxes(.horizontal)
            SummaryRow(
                title: "checkIn.segment.you",
                count: summary?.currentUserTotalCheckIns,
                rating: summary?.currentUserAverageRating
            )
        }
    }

    private var header: some View {
        GridRow {
            Text("")
            Spacer()
            Text("summary.check-ins")
                .font(.caption).bold()
            Spacer()
            Text("summary.rating")
                .font(.caption).bold()
        }
    }
}

struct SummaryRow: View {
    let title: LocalizedStringKey
    let count: Int?
    let rating: Double?

    var body: some View {
        GridRow {
            Text(title).font(.caption).bold()
            Spacer()
            if let count {
                Text(count.formatted())
                    .contentTransition(.numericText())
                    .font(.caption)
            } else {
                Text("")
            }
            Spacer()
            RatingView(rating: rating ?? 0, type: .small)
            Group {
                if let rating {
                    Text(rating.formatted(
                        .number.precision(.fractionLength(2))))
                        .contentTransition(.numericText()
                        )
                } else {
                    Text("-")
                }
            }
            .font(.caption)
            .bold()
        }
    }
}
