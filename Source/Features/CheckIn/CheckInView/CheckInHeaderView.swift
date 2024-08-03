import Components

import Models
import SwiftUI

struct CheckInHeaderView: View {
    @Environment(\.checkInLoadedFrom) private var checkInLoadedFrom
    let profile: Profile.Saved
    let location: Location.Saved?

    var body: some View {
        RouterLink(open: .screen(.profile(profile))) {
            HStack {
                AvatarView(profile: profile)
                    .avatarSize(.large)
                Text(profile.preferredName)
                    .font(.caption).bold()
                    .foregroundColor(.primary)
                Spacer()
                if let location {
                    RouterLink(open: .screen(.location(location.id))) {
                        Text(location.formatted(.withEmoji))
                            .font(.caption).bold()
                            .foregroundColor(.primary)
                            .contentShape(.rect)
                    }
                    .routerLinkDisabled(checkInLoadedFrom.isLoadedFromLocation(location))
                }
            }
            .contentShape(.rect)
        }
        .routerLinkDisabled(checkInLoadedFrom.isLoadedFromProfile(profile))
    }
}
