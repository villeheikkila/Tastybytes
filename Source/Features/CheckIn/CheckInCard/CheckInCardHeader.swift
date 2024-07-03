import Components
import EnvironmentModels
import Models
import SwiftUI

struct CheckInCardHeader: View {
    let profile: Profile
    let loadedFrom: CheckInCard.LoadedFrom
    let location: Location?

    var body: some View {
        HStack {
            Avatar(profile: profile)
                .avatarSize(.large)
            Text(profile.preferredName)
                .font(.caption).bold()
                .foregroundColor(.primary)
            Spacer()
            if let location {
                Text(location.formatted(.withEmoji))
                    .font(.caption).bold()
                    .foregroundColor(.primary)
                    .contentShape(.rect)
                    .accessibilityAddTraits(.isLink)
                    .allowsHitTesting(!loadedFrom.isLoadedFromLocation(location))
                    .openOnTap(.screen(.location(location)))
            }
        }
        .contentShape(.rect)
        .accessibilityAddTraits(.isLink)
        .allowsHitTesting(!loadedFrom.isLoadedFromProfile(profile))
        .openOnTap(.screen(.profile(profile)))
    }
}
