import Models
import SwiftUI

struct ProfileLinksSection: View {
    let profile: Profile
    let isCurrentUser: Bool

    var body: some View {
        VStack(spacing: 3) {
            Group {
                RouterLink(
                    "Friends",
                    systemImage: "person.crop.rectangle.stack",
                    screen: isCurrentUser ? .currentUserFriends : .friends(profile)
                )
                RouterLink("Check-ins", systemImage: "checkmark.rectangle", screen: .profileProducts(profile))
                RouterLink("Statistics", systemImage: "chart.bar.xaxis", screen: .profileStatistics(profile))
                RouterLink("Wishlist", systemImage: "heart", screen: .profileWishlist(profile))
                if isCurrentUser {
                    RouterLink("Locations", systemImage: "map", screen: .profileLocations(profile))
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
