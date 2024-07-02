import Components
import Models
import SwiftUI

struct TaggedInCheckInNotificationView: View {
    let checkIn: CheckIn
    let createdAt: Date
    let seenAt: Date?

    var body: some View {
        RouterLink(open: .screen(.checkIn(checkIn)), asTapGesture: true) {
            NotificationFromUserWrapper(profile: checkIn.profile, createdAt: createdAt) {
                Text(
                    "notification.taggedCheckIn.userTaggedYou \(checkIn.profile.preferredName) \(checkIn.product.formatted(.full))"
                )
            }
        }
        .buttonStyle(.plain)
    }
}
