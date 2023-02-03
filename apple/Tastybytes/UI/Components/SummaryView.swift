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
    .padding([.leading, .trailing], 10)
    .padding(.top, 5)
  }

  private var header: some View {
    GridRow {
      Text("")
      Spacer()
      Text("Check-ins")
        .font(.system(size: 10, weight: .bold, design: .default))
      Spacer()
      Text("Rating")
        .font(.system(size: 10, weight: .bold, design: .default))
    }
  }

  @ViewBuilder
  private var everyoneSection: some View {
    if let averageRating = summary.averageRating {
      GridRow {
        Text("Everyone")
          .font(.system(size: 10, weight: .bold, design: .default))
        Spacer()
        Text(String(summary.totalCheckIns))
          .font(.system(size: 10, weight: .medium, design: .default))
        Spacer()
        RatingView(rating: averageRating, type: .small)
      }
      Divider()
        .gridCellUnsizedAxes(.horizontal)
    }
  }

  @ViewBuilder
  private var friendsSection: some View {
    if let friendsAverageRating = summary.friendsAverageRating {
      GridRow {
        Text("Friends")
          .font(.system(size: 10, weight: .bold, design: .default))
        Spacer()
        Text(String(summary.friendsTotalCheckIns))
          .font(.system(size: 10, weight: .medium, design: .default))
        Spacer()
        RatingView(rating: friendsAverageRating, type: .small)
      }
      Divider()
        .gridCellUnsizedAxes(.horizontal)
    }
  }

  @ViewBuilder
  private var youSection: some View {
    if let currentUserAverageRating = summary.currentUserAverageRating {
      GridRow {
        Text("You")
          .font(.system(size: 10, weight: .bold, design: .default))
        Spacer()
        Text(String(summary.currentUserTotalCheckIns))
          .font(.system(size: 10, weight: .medium, design: .default))
        Spacer()
        RatingView(rating: currentUserAverageRating, type: .small)
      }
    }
  }
}