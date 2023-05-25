import SwiftUI

struct CheckInCommentNotificationView: View {
  let checkInComment: CheckInComment.Joined

  var body: some View {
    RouterLink(screen: .checkIn(checkInComment.checkIn)) {
      HStack {
        AvatarView(avatarUrl: checkInComment.profile.avatarUrl, size: 32, id: checkInComment.profile.id)
        Text(
          """
          \(checkInComment.profile.preferredName)\
           commented on your check-in of\
          \(checkInComment.checkIn.product.getDisplayName(.full))
          """
        )
        Spacer()
      }
    }
    .buttonStyle(.plain)
  }
}
