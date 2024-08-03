import Models
import SwiftUI

struct CreationInfoHeaderView: View {
    let createdBy: Profile.Saved?
    let createdAt: Date
    let resolvedAt: Date?

    init(createdBy: Profile.Saved?, createdAt: Date, resolvedAt: Date? = nil) {
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.resolvedAt = resolvedAt
    }

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
            VStack(alignment: .leading, spacing: 2) {
                Text("\(Image(systemName: "calendar.badge.plus")) \(createdAt.formatted(.customRelativetime))").font(.caption2)
                if let resolvedAt {
                    Text("\(Image(systemName: "calendar.badge.checkmark")) \(resolvedAt.formatted(.customRelativetime))")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }
        }
    }
}
