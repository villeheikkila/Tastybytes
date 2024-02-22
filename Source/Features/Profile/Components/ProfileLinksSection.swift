import Models
import SwiftUI

struct ProfileLinksSection: View {
    let profile: Profile
    let isCurrentUser: Bool

    var body: some View {
            Group {
                RouterLink(
                    "profile.links.friends",
                    systemImage: "person.crop.rectangle.stack",
                    screen: isCurrentUser ? .currentUserFriends : .friends(profile),
                    asTapGesture: true
                )
                RouterLink("profile.links.checkIns", systemImage: "checkmark.rectangle", screen: .profileProducts(profile), asTapGesture: true)
                RouterLink("profile.links.statistics", systemImage: "chart.bar.xaxis", screen: .profileStatistics(profile), asTapGesture: true)
                RouterLink("profile.links.wishlist", systemImage: "heart", screen: .profileWishlist(profile), asTapGesture: true)
                if isCurrentUser {
                    RouterLink("profile.links.locations", systemImage: "map", screen: .profileLocations(profile), asTapGesture: true)
                }
            }
            .font(.subheadline)
            .bold()
            .foregroundColor(.blue)
            .padding()
            .background(.gray.quinary)
            .cornerRadius(8.0)
    }
}
