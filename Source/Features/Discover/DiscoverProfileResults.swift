import Models
import SwiftUI

struct DiscoverProfileResults: View {
    let profiles: [Profile.Saved]

    var body: some View {
        ForEach(profiles) { profile in
            RouterLink(open: .screen(.profile(profile))) {
                ProfileEntityView(profile: profile)
                    .padding(.vertical, 10)
            }
            .id(profile.id)
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                0
            }
        }
    }
}
