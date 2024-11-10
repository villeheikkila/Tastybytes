import SwiftUI

struct EmptyActivityListView: View {
    var body: some View {
        ContentUnavailableView {
            Label("activityFeed.emptyContent.title", systemImage: "list.star")
        } description: {
            Text("activityFeed.emptyContent.description")
        }
    }
}

#Preview {
    EmptyActivityListView()
}
