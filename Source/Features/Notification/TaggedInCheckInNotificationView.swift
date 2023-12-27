import Components
import Models
import SwiftUI

struct TaggedInCheckInNotificationView: View {
    let checkIn: CheckIn

    var body: some View {
        RouterLink(screen: .checkIn(checkIn)) {
            HStack {
                AvatarView(avatarUrl: checkIn.profile.avatarUrl, size: 32, id: checkIn.profile.id)
                Text(
                    "\(checkIn.profile.preferredName) tagged you in a check-in of \(checkIn.product.getDisplayName(.full))"
                )
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
