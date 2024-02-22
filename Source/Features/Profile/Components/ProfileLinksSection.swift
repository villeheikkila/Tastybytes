import Models
import SwiftUI

struct ProfileLinksSection: View {
    let profile: Profile
    let isCurrentUser: Bool

    var body: some View {
        Group {
            RouterLink("profile.links.friends",
                       systemImage: "person.crop.rectangle.stack",
                       screen: isCurrentUser ? .currentUserFriends : .friends(profile))
            RouterLink("profile.links.checkIns", systemImage: "checkmark.rectangle", screen: .profileProducts(profile))
            RouterLink("profile.links.statistics", systemImage: "chart.bar.xaxis", screen: .profileStatistics(profile))
            RouterLink("profile.links.wishlist", systemImage: "heart", screen: .profileWishlist(profile))
            if isCurrentUser {
                RouterLink("profile.links.locations", systemImage: "map", screen: .profileLocations(profile))
            }
        }
        .listRowSeparator(.visible)
        .font(.subheadline)
        .bold()
        .cornerRadius(8.0)
    }
}
