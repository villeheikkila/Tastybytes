import Components
import Models
import SwiftUI

struct CheckInCardHeader: View {
    @Environment(Router.self) private var router

    public let profile: Profile
    public let loadedFrom: CheckInCard.LoadedFrom
    public let location: Location?

    var body: some View {
        HStack {
            AvatarView(profile: profile)
            Text(profile.preferredName)
                .font(.caption).bold()
                .foregroundColor(.primary)
            Spacer()
            if let location {
                Text("\(location.name) \(location.country?.emoji ?? "")")
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
