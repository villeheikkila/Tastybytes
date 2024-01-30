import Components
import Models
import SwiftUI

struct CheckInReactionNotificationView: View {
    let checkInReaction: CheckInReaction.JoinedCheckIn

    var body: some View {
        RouterLink(screen: .checkIn(checkInReaction.checkIn)) {
            HStack {
                Avatar(profile: checkInReaction.profile, size: 32)
                Text(
                    """
                    \(checkInReaction.profile.preferredName)\
                     reacted to your check-in of\
                     \(checkInReaction.checkIn.product.formatted(.full))
                    """
                )
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
