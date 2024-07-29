import Components

import Models
import SwiftUI

struct CheckInCardHeader: View {
    @Environment(\.checkInCardLoadedFrom) private var checkInCardLoadedFrom
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
                    .routerLinkDisabled(checkInCardLoadedFrom.isLoadedFromLocation(location))
                }
            }
            .contentShape(.rect)
        }
        .routerLinkDisabled(checkInCardLoadedFrom.isLoadedFromProfile(profile))
    }
}
