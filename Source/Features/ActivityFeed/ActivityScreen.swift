import SwiftUI
import Models

struct ActivityScreen: View {
    @State private var checkIns = [CheckIn]()
    @Binding var scrollToTop: Int

    var body: some View {
        CheckInList(
            id: "ActivityScreen",
            fetcher: .activityFeed,
            checkIns: $checkIns,
            scrollToTop: $scrollToTop,
            showContentUnavailableView: true
        )
    }
}
