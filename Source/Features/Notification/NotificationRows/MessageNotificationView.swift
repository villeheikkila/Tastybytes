import SwiftUI

@MainActor
struct MessageNotificationView: View {
    let message: String

    var body: some View {
        Text(message)
    }
}
