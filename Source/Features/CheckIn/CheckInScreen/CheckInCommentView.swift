import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInCommentView: View {
    let comment: CheckInComment

    var body: some View {
        HStack {
            Avatar(profile: comment.profile, size: 32)
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.profile.preferredName).font(.caption)
                    Spacer()
                    Text(comment.createdAt.relativeTime).font(.caption2).bold()
                }
                Text(comment.content).font(.callout)
            }
            Spacer()
        }
    }
}
