import Models
import SwiftUI

@MainActor
struct ProfileStatisticsScreen: View {
    let profile: Profile

    var body: some View {
        List {
            CheckInsByTimeBucketView(profile: profile)
            Section("profileStatistics.links.title") {
                RouterLink("profileStatistics.uniqueByCategory.label", screen: .profileStatisticsUniqueProducts(profile))
                RouterLink("profileStatistics.topLocations.label", screen: .profileStatisticsTopLocations(profile))
                RouterLink("profileStatistics.topProducts.label", screen: .profileProductsByFilter(profile, .init(sortBy: .highestRated)))
            }.headerProminence(.increased)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("profileStatistics.navigationTitle")
    }
}
