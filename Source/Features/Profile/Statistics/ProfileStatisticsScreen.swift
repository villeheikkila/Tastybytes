import Models
import SwiftUI

@MainActor
struct ProfileStatisticsScreen: View {
    let profile: Profile

    var body: some View {
        List {
            CheckInsByTimeBucketView(profile: profile)
            Section("profileStatistics.links.title") {
                RouterLink("profileStatistics.uniqueByCategory.label", systemImage: "1.circle", screen: .profileStatisticsUniqueProducts(profile))
            }.headerProminence(.increased)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("profileStatistics.navigationTitle")
    }
}
