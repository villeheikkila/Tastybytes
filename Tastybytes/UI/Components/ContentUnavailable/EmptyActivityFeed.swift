import SwiftUI

struct EmptyActivityFeed: View {
    var body: some View {
        ContentUnavailableView {
            Label("Activity feed is empty", systemSymbol: .listStar)
        } description: {
            Text("Start by adding friends or by making your check-in!")
        }
    }
}

#Preview {
    EmptyActivityFeed()
}
