import Components
import EnvironmentModels
import Models
import SwiftUI

struct ProfileSummarySection: View {
    @Environment(Router.self) private var router

    let profile: Profile.Saved
    let profileSummary: ProfileSummary?

    var body: some View {
        HStack {
            Spacer()
            CheckInStatisticView(title: "profile.summary.unrated", subtitle: .init(stringLiteral: profileSummary?.unrated.formatted() ?? "0")) {
                router.open(.screen(.profileProductsByFilter(profile, Product.Filter(onlyUnrated: true))))
            }
            SpacingView(width: 12)
            Divider()
            SpacingView(width: 12)
            CheckInStatisticView(title: "profile.summary.average", subtitle: .init(stringLiteral: profileSummary?.averageRating?.formatted(.number.precision(.fractionLength(2))) ?? "-")) {
                router.open(.screen(.profileProductsByFilter(profile, Product.Filter(sortBy: .highestRated))))
            }
            Spacer()
        }
    }
}
