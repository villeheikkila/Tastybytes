import SwiftUI

struct CheckInReactionNotificationView: View {
  let checkInReaction: CheckInReaction.JoinedCheckIn

  var body: some View {
    RouteLink(to: .checkIn(checkInReaction.checkIn)) {
      HStack {
        AvatarView(avatarUrl: checkInReaction.profile.avatarUrl, size: 32, id: checkInReaction.profile.id)
        Text(
          """
          \(checkInReaction.profile.preferredName)\
           reacted to your check-in of\
           \(checkInReaction.checkIn.product.getDisplayName(.full))
          """
        )

        Spacer()
      }
    }
    .buttonStyle(.plain)
  }
}
