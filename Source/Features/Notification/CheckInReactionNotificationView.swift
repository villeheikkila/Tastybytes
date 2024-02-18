import Components
import Models
import SwiftUI

struct CheckInReactionNotificationView: View {
    let checkInReaction: CheckInReaction.JoinedCheckIn

    var body: some View {
        RouterLink(screen: .checkIn(checkInReaction.checkIn)) {
            HStack {
                Avatar(profile: checkInReaction.profile)
                    .avatarSize(.large)
                Text("checkIn.notifications.userReactedToYourCheckIn.body \(checkInReaction.profile.preferredName) \(checkInReaction.checkIn.product.formatted(.full))")
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
