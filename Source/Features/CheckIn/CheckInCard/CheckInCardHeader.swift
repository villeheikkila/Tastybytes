import Components
import EnvironmentModels
import Models
import SwiftUI

struct CheckInCardHeader: View {
    @Environment(Router.self) private var router

    public let profile: Profile
    public let loadedFrom: CheckInCard.LoadedFrom
    public let location: Location?

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
                    .contentShape(Rectangle())
                    .accessibilityAddTraits(.isLink)
                    .allowsHitTesting(!loadedFrom.isLoadedFromLocation(location))
                    .onTapGesture {
                        router.navigate(screen: .location(location))
                    }
            }
        }
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isLink)
        .allowsHitTesting(!loadedFrom.isLoadedFromProfile(profile))
        .onTapGesture {
            router.navigate(screen: .profile(profile))
        }
    }
}
