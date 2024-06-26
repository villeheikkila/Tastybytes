import Components
import Models
import SwiftUI

struct CheckInCommentNotificationView: View {
    let checkInComment: CheckInComment.Joined
    let createdAt: Date
    let seenAt: Date?

    var body: some View {
        RouterLink(screen: .checkIn(checkInComment.checkIn), asTapGesture: true) {
            NotificationFromUserWrapper(profile: checkInComment.profile, createdAt: createdAt) {
                Text("notification.checkInComment.userCommentedOnYourCheckIn \(checkInComment.profile.preferredName) \(checkInComment.checkIn.product.formatted(.full))")
            }
        }
        .buttonStyle(.plain)
    }
}
