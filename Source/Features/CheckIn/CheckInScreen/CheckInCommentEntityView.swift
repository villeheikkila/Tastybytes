import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInCommentEntityView: View {
    let comment: CheckInCommentProtocol

    var body: some View {
        HStack {
            AvatarView(profile: comment.profile)
                .avatarSize(.medium)
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.profile.preferredName).font(.caption)
                    Spacer()
                    Text(comment.createdAt.formatted(.customRelativetime)).font(.caption2).bold()
                }
                Text(comment.content).font(.callout)
            }
            Spacer()
        }
    }
}
