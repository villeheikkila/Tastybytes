import SwiftUI

struct SummaryView: View {
  let summary: Summary

  var body: some View {
    Grid(alignment: .leading) {
      header
      Divider()
        .gridCellUnsizedAxes(.horizontal)
      everyoneSection
      friendsSection
      youSection
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

  @ViewBuilder private var everyoneSection: some View {
    if let averageRating = summary.averageRating {
      GridRow {
        Text("Everyone")
          .font(.caption).bold()
        Spacer()
        Text(String(summary.totalCheckIns))
          .font(.caption)
        Spacer()
        RatingView(rating: averageRating, type: .small)
        Text(String(averageRating))
          .font(.caption).bold()
      }
      Divider()
        .gridCellUnsizedAxes(.horizontal)
    }
  }

  @ViewBuilder private var friendsSection: some View {
    if let friendsAverageRating = summary.friendsAverageRating {
      GridRow {
        Text("Friends")
          .font(.caption).bold()
        Spacer()
        Text(String(summary.friendsTotalCheckIns))
          .font(.caption)
        Spacer()
        RatingView(rating: friendsAverageRating, type: .small)
        Text(String(friendsAverageRating))
          .font(.caption).bold()
      }
      Divider()
        .gridCellUnsizedAxes(.horizontal)
    }
  }

  @ViewBuilder private var youSection: some View {
    if let currentUserAverageRating = summary.currentUserAverageRating {
      GridRow {
        Text("You")
          .font(.caption)
        Spacer()
        Text(String(summary.currentUserTotalCheckIns))
          .font(.caption)
        Spacer()
        RatingView(rating: currentUserAverageRating, type: .small)
        Text(String(currentUserAverageRating))
          .font(.caption).bold()
      }
    }
  }
}
