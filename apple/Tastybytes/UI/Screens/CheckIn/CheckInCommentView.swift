import SwiftUI

struct CheckInCommentView: View {
  let comment: CheckInComment

  var body: some View {
    HStack {
      AvatarView(avatarUrl: comment.profile.avatarUrl, size: 32, id: comment.profile.id)
      VStack(alignment: .leading) {
        HStack {
          Text(comment.profile.preferredName).font(.system(size: 12, weight: .medium, design: .default))
          Spacer()
          Text(comment.createdAt.relativeTime()).font(.system(size: 8, weight: .medium, design: .default))
        }
        Text(comment.content).font(.system(size: 14, weight: .light, design: .default))
      }
      Spacer()
    }
  }
}
