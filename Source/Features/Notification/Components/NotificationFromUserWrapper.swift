import Components
import Models
import SwiftUI

struct NotificationFromUserWrapper<Content: View>: View {
    let profile: Profile.Saved
    let createdAt: Date
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .top) {
            Avatar(profile: profile)
                .avatarSize(.large)
                .padding(.top, 2)
                .padding(.trailing, 3)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(profile.preferredName).font(.caption).bold()
                    Spacer()
                    Text(createdAt.formatted(.customRelativetime)).font(.caption2)
                }
                content()
            }
            Spacer()
        }
        .padding(.vertical, 2)
        .listRowBackground(Color.clear)
    }
}
