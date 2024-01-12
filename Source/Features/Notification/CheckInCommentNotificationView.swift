import Components
import Models
import SwiftUI

struct CheckInCommentNotificationView: View {
    let checkInComment: CheckInComment.Joined

    var body: some View {
        RouterLink(screen: .checkIn(checkInComment.checkIn)) {
            HStack {
                Avatar(profile: checkInComment.profile, size: 32)
                Text(
                    """
                    \(checkInComment.profile.preferredName)\
                     commented on your check-in of \
                    \(checkInComment.checkIn.product.getDisplayName(.full))
                    """
                )
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
