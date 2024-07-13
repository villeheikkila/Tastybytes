import Components
import Models
import SwiftUI

struct CheckInCardTaggedFriends: View {
    let taggedProfiles: [Profile]
    let loadedFrom: CheckInCard.LoadedFrom

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
                            Avatar(profile: taggedProfile)
                        }
                        .routerLinkDisabled(loadedFrom.isLoadedFromProfile(taggedProfile))
                    }
                    Spacer()
                }
            }
        }
    }
}
