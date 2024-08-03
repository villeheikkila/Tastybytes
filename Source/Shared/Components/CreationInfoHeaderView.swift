import SwiftUI
import Models

struct CreationInfoHeaderView: View {
    let createdBy: Profile.Saved?
    let createdAt: Date

    var body: some View {
        HStack(alignment: .center) {
            if let createdBy {
                AvatarView(profile: createdBy)
                    .avatarSize(.medium)
                Text(createdBy.preferredName)
                    .font(.caption).bold()
                    .foregroundColor(.primary)
            }
            Spacer()
            Text(createdAt.formatted(.customRelativetime))
                .font(.caption)
        }
    }
}
