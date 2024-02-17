import Components
import Models
import SwiftUI

struct CheckInCommentNotificationView: View {
    let checkInComment: CheckInComment.Joined

    var body: some View {
        RouterLink(screen: .checkIn(checkInComment.checkIn)) {
            HStack {
                Avatar(profile: checkInComment.profile, size: 32)
                Text("notification.checkInComment.userCommentedOnYourCheckIn \(checkInComment.profile.preferredName) \(checkInComment.checkIn.product.formatted(.full))"
                )
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
