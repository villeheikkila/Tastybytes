import Components
import Models
import SwiftUI

struct CheckInTaggedFriendsView: View {
    @Environment(\.checkInLoadedFrom) private var checkInLoadedFrom
    let taggedProfiles: [Profile.Saved]

    var body: some View {
        if !taggedProfiles.isEmpty {
            VStack(spacing: 4) {
                HStack {
                    Text(verbatim: "Tagged friends")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                HStack(spacing: 4) {
                    ForEach(taggedProfiles) { taggedProfile in
                        RouterLink(open: .screen(.profile(taggedProfile))) {
                            AvatarView(profile: taggedProfile)
                        }
                        .routerLinkDisabled(checkInLoadedFrom.isLoadedFromProfile(taggedProfile))
                    }
                    Spacer()
                }
            }
        }
    }
}
