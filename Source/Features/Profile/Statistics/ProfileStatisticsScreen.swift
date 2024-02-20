import Models
import SwiftUI

struct ProfileStatisticsScreen: View {
    let profile: Profile

    var body: some View {
        List {
            TimePeriodStatisticView(profile: profile)
            Section("profileStatistics.links.title") {
                RouterLink("profileStatistics.uniqueByCategory.label", systemImage: "1.circle", screen: .profileStatisticsUniqueProducts(profile))
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("profileStatistics.navigationTitle")
    }
}
