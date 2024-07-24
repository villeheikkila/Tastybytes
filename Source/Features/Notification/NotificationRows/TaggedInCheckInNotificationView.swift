import Components
import Models
import SwiftUI

struct TaggedInCheckInNotificationView: View {
    let checkIn: CheckIn.Joined
    let createdAt: Date
    let seenAt: Date?

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkIn))) {
            NotificationFromUserWrapper(profile: checkIn.profile, createdAt: createdAt) {
                Text(
                    "notification.taggedCheckIn.userTaggedYou \(checkIn.profile.preferredName) \(checkIn.product.formatted(.full))"
                )
            }
        }
    }
}
