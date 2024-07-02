import Models
import SwiftUI

struct ProfileLinksSection: View {
    let profile: Profile
    let isCurrentUser: Bool

    var body: some View {
        Group {
            RouterLink("profile.links.friends",
                       systemImage: "person.crop.rectangle.stack",
                       open: .screen(isCurrentUser ? .currentUserFriends : .friends(profile)))
            RouterLink("profile.links.checkIns", systemImage: "checkmark.rectangle", open: .screen(.profileProducts(profile)))
            RouterLink("profile.links.statistics", systemImage: "chart.bar.xaxis", open: .screen(.profileStatistics(profile)))
            RouterLink("profile.links.wishlist", systemImage: "heart", open: .screen(.profileWishlist(profile)))
            if isCurrentUser {
                RouterLink("profile.links.locations", systemImage: "map", open: .screen(.profileLocations(profile)))
            }
        }
        .listRowSeparator(.visible)
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
        .font(.subheadline)
        .bold()
        .cornerRadius(8.0)
    }
}
