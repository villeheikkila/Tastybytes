import Components
import Models
import SwiftUI

struct CheckInCommentNotificationView: View {
    let checkInComment: CheckIn.Comment.Joined
    let createdAt: Date
    let seenAt: Date?

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkInComment.checkIn))) {
            NotificationFromUserWrapper(profile: checkInComment.profile, createdAt: createdAt) {
                Text("notification.checkInComment.userCommentedOnYourCheckIn \(checkInComment.profile.preferredName) \(checkInComment.checkIn.product.formatted(.full))")
            }
        }
    }
}
