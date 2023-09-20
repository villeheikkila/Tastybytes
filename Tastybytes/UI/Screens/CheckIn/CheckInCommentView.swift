import Components
import Extensions
import Models
import SwiftUI

struct CheckInCommentView: View {
    let comment: CheckInComment

    var body: some View {
        HStack {
            AvatarView(avatarUrl: comment.profile.avatarUrl, size: 32, id: comment.profile.id)
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.profile.preferredName).font(.caption)
                    Spacer()
                    Text(comment.createdAt.customFormat(.relativeTime)).font(.caption2).bold()
                }
                Text(comment.content).font(.callout)
            }
            Spacer()
        }
    }
}
