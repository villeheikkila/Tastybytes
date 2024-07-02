import Models
import SwiftUI

struct ProfileStatisticsScreen: View {
    let profile: Profile

    var body: some View {
        List {
            CheckInsByTimeBucketView(profile: profile)
            Section("profileStatistics.links.title") {
                RouterLink("profileStatistics.uniqueByCategory.label", open: .screen(.profileStatisticsUniqueProducts(profile)))
                RouterLink("profileStatistics.topLocations.label", open: .screen(.profileStatisticsTopLocations(profile)))
                RouterLink("profileStatistics.topProducts.label", open: .screen(.profileProductsByFilter(profile, .init(sortBy: .highestRated))))
            }.headerProminence(.increased)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("profileStatistics.navigationTitle")
    }
}
