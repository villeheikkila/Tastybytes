import Components
import Models
import SwiftUI

@MainActor
struct CheckInReactionNotificationView: View {
    let checkInReaction: CheckInReaction.JoinedCheckIn
    let createdAt: Date
    let seenAt: Date?

    var body: some View {
        RouterLink(screen: .checkIn(checkInReaction.checkIn), asTapGesture: true) {
            NotificationFromUserWrapper(profile: checkInReaction.profile, createdAt: createdAt) {
                Text("checkIn.notifications.userReactedToYourCheckIn.body \(checkInReaction.profile.preferredName) \(checkInReaction.checkIn.product.formatted(.full))")
            }
        }
        .buttonStyle(.plain)
    }
}
