import SwiftUI

struct ActivityScreen: View {
  @Binding var scrollToTop: Int

  var body: some View {
    CheckInListView(
      fetcher: .activityFeed,
      scrollToTop: $scrollToTop,
      onRefresh: {},
      header: {}
    )
  }
}
