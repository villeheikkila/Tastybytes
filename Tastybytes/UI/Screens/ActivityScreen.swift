import SwiftUI

struct ActivityScreen: View {
    @Binding var scrollToTop: Int
    @Environment(Router.self) private var router

    let navigateToDiscoverTab: () -> Void

    var body: some View {
        CheckInListView(
            fetcher: .activityFeed,
            scrollToTop: $scrollToTop,
            onRefresh: {},
            showContentUnavailableView: true,
            emptyView: {},
            header: {}
        )
    }
}
