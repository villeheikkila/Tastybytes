import SwiftUI

struct SummaryView: View {
  let summary: Summary

  var body: some View {
    Grid(alignment: .leading) {
      header
      Divider().gridCellUnsizedAxes(.horizontal)
      if let averageRating = summary.averageRating {
        SummaryRow(title: "Everyone", count: summary.totalCheckIns, rating: averageRating)
        Divider().gridCellUnsizedAxes(.horizontal)
      }
      if let friendsAverageRating = summary.friendsAverageRating {
        SummaryRow(title: "Friends", count: summary.friendsTotalCheckIns, rating: friendsAverageRating)
        Divider().gridCellUnsizedAxes(.horizontal)
      }
      if let currentUserAverageRating = summary.currentUserAverageRating {
        SummaryRow(title: "You", count: summary.currentUserTotalCheckIns, rating: currentUserAverageRating)
      }
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
  let count: Int
  let rating: Double

  var body: some View {
    GridRow {
      Text(title).font(.caption).bold()
      Spacer()
      Text(String(count)).font(.caption)
      Spacer()
      RatingView(rating: rating, type: .small)
      Text(String(rating)).font(.caption).bold()
    }
  }
}
