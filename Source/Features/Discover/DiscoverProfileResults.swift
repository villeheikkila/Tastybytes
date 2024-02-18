import Models
import SwiftUI

struct DiscoverProfileResults: View {
    let profiles: [Profile]

    var body: some View {
        ForEach(profiles) { profile in
            RouterLink(screen: .profile(profile)) {
                HStack(alignment: .center) {
                    Avatar(profile: profile)
                        .avatarSize(.extraLarge)
                    VStack {
                        HStack {
                            Text(profile.preferredName)
                                .padding(.leading, 8)
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .id(profile.id)
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                0
            }
        }
    }
}
