import SwiftUI

struct ActivityScreen: View {
    @Binding var scrollToTop: Int
    @Environment(Router.self) private var router

    var body: some View {
        CheckInListView(
            fetcher: .activityFeed,
            scrollToTop: $scrollToTop,
            onRefresh: {},
            showContentUnavailableView: true,
            header: {}
        )
    }
}
