import SwiftUI

 struct EmptyActivityFeedView: View {

     var body: some View {
        ContentUnavailableView {
            Label("activityFeed.emptyContent.title", systemImage: "list.star")
        } description: {
            Text("activityFeed.emptyContent.description")
        }
    }
}

#Preview {
    EmptyActivityFeedView()
}
