import Components
import Models
import SwiftUI

struct TaggedInCheckInNotificationView: View {
    let checkIn: CheckIn

    var body: some View {
        RouterLink(screen: .checkIn(checkIn)) {
            HStack {
                Avatar(profile: checkIn.profile, size: 32)
                Text(
                    "\(checkIn.profile.preferredName) tagged you in a check-in of \(checkIn.product.getDisplayName(.full))"
                )
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
