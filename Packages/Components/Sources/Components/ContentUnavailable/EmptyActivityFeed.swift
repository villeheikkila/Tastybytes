import SwiftUI

public struct EmptyActivityFeed: View {
    public init() {}

    public var body: some View {
        ContentUnavailableView {
            Label("activityFeed.emptyContent.title", systemImage: "list.star")
        } description: {
            Text("activityFeed.emptyContent.description")
        }
    }
}

#Preview {
    EmptyActivityFeed()
}
