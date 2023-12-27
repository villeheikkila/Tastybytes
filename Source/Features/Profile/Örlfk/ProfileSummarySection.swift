import Components
import EnvironmentModels
import Models
import SwiftUI

struct ProfileSummarySection: View {
    @Environment(Router.self) private var router
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel

    let profile: Profile
    let profileSummary: ProfileSummary?

    var body: some View {
        HStack {
            Spacer()
            CheckInStatisticView(title: "Unrated", subtitle: String(profileSummary?.unrated ?? 0)) {
                router.navigate(screen: .profileProductsByFilter(profile, Product.Filter(onlyUnrated: true)))
            }
            Spacing(width: 12)
            Divider()
            Spacing(width: 12)
            CheckInStatisticView(title: "Average", subtitle: profileSummary?.averageRating.toRatingString ?? "-") {
                router.navigate(screen: .profileProductsByFilter(profile, Product.Filter(sortBy: .highestRated)))
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }
}
