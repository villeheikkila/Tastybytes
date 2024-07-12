import Components
import EnvironmentModels
import Models
import SwiftUI

struct CheckInCardHeader: View {
    let profile: Profile
    let loadedFrom: CheckInCard.LoadedFrom
    let location: Location?

    var body: some View {
        RouterLink(open: .screen(.profile(profile))) {
            HStack {
                Avatar(profile: profile)
                    .avatarSize(.large)
                Text(profile.preferredName)
                    .font(.caption).bold()
                    .foregroundColor(.primary)
                Spacer()
                if let location {
                    RouterLink(open: .screen(.location(location))) {
                        Text(location.formatted(.withEmoji))
                            .font(.caption).bold()
                            .foregroundColor(.primary)
                            .contentShape(.rect)
                            .accessibilityAddTraits(.isLink)
                            .allowsHitTesting(!loadedFrom.isLoadedFromLocation(location))
                    }
                }
            }
            .contentShape(.rect)
            .accessibilityAddTraits(.isLink)
            .allowsHitTesting(!loadedFrom.isLoadedFromProfile(profile))
        }
    }
}
