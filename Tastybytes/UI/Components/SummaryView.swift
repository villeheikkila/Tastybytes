import Models
import SwiftUI

struct SummaryView: View {
    public let summary: Summary?

    var body: some View {
        Grid(alignment: .leading) {
            header
            Divider().gridCellUnsizedAxes(.horizontal)
            SummaryRow(title: "Everyone", count: summary?.totalCheckIns, rating: summary?.averageRating)
            Divider().gridCellUnsizedAxes(.horizontal)
            SummaryRow(title: "Friends", count: summary?.friendsTotalCheckIns, rating: summary?.friendsAverageRating)
            Divider().gridCellUnsizedAxes(.horizontal)
            SummaryRow(
                title: "You",
                count: summary?.currentUserTotalCheckIns,
                rating: summary?.currentUserAverageRating
            )
        }
    }

    private var header: some View {
        GridRow {
            Text("")
            Spacer()
            Text("Check-ins")
                .font(.caption).bold()
            Spacer()
            Text("Rating")
                .font(.caption).bold()
        }
    }
}

struct SummaryRow: View {
    let title: String
    let count: Int?
    let rating: Double?

    var body: some View {
        GridRow {
            Text(title).font(.caption).bold()
            Spacer()
            if let count {
                Text(String(count)).font(.caption)
            } else {
                Text("")
            }
            Spacer()
            RatingView(rating: rating ?? 0, type: .small)
            Group {
                if let rating {
                    Text(String(rating))
                } else {
                    Text("-")
                }
            }.font(.caption).bold()
        }
    }
}
