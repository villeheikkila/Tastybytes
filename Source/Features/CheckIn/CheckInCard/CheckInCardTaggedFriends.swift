import Components
import Models
import SwiftUI

@MainActor
struct CheckInCardTaggedFriends: View {
    @Environment(Router.self) private var router

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
                        Avatar(profile: taggedProfile)
                            .contentShape(Rectangle())
                            .accessibilityAddTraits(.isLink)
                            .allowsHitTesting(!loadedFrom.isLoadedFromProfile(taggedProfile))
                            .onTapGesture {
                                router.navigate(screen: .profile(taggedProfile))
                            }
                    }
                    Spacer()
                }
            }
        }
    }
}
