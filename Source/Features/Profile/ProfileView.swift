import Models
import SwiftUI

struct ProfileView: View {
    let profile: ProfileProtocol

    var body: some View {
        HStack(alignment: .center) {
            AvatarView(profile: profile)
                .avatarSize(.extraLarge)
            Text(profile.preferredName)
                .padding(.leading, 8)
            Spacer()
        }
        .contentShape(.rect)
    }
}
