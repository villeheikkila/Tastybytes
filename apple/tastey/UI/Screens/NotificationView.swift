import SwiftUI

struct NotificationView: View {
    let profile: Profile
    var body: some View {
        ScrollView {
            if let notifications = profile.notifications {
                ForEach(notifications) {
                    notification in Text(notification.message)
                }
            }
        }
    }
}
