import Models
import SwiftUI

struct ProfileLinksSection: View {
    let profile: Profile
    let isCurrentUser: Bool

    var body: some View {
        VStack(spacing: 3) {
            Group {
                RouterLink(
                    "profile.links.friends",
                    systemImage: "person.crop.rectangle.stack",
                    screen: isCurrentUser ? .currentUserFriends : .friends(profile)
                )
                RouterLink("profile.links.checkIns", systemImage: "checkmark.rectangle", screen: .profileProducts(profile))
                RouterLink("profile.links.statistics", systemImage: "chart.bar.xaxis", screen: .profileStatistics(profile))
                RouterLink("profile.links.wishlist", systemImage: "heart", screen: .profileWishlist(profile))
                if isCurrentUser {
                    RouterLink("profile.links.locations", systemImage: "map", screen: .profileLocations(profile))
                }
            }
            .font(.subheadline)
            .bold()
            .foregroundColor(Color.blue)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8.0)
        }
    }
}
