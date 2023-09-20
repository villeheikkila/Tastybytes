import SwiftUI

public struct EmptyActivityFeed: View {
    public var body: some View {
        ContentUnavailableView {
            Label("Activity feed is empty", systemImage: "list.start")
        } description: {
            Text("Start by adding friends or by making your check-in!")
        }
    }
}

#Preview {
    EmptyActivityFeed()
}
