import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInsByDayChart: View {
    private let logger = Logger(category: "TimePeriodStatisticView")
    @Environment(Repository.self) private var repository
    @State private var timePeriod: TimePeriodStatistic.TimePeriod = .week
    @State private var isLoading = false
    @State private var timePeriodStatistics = [CheckInsPerDay]()

    init(profile: Profile) {
        self.profile = profile
    }

    let profile: Profile

    var body: some View {
        Section {
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .task {
            await loadStatisticsForTimePeriod()
        }
    }

    func loadStatisticsForTimePeriod() async {
        guard isLoading == false else { return }
        isLoading = true
        print("HEEYOO")
        switch await repository.profile.getCheckInsPerDayForYear(.init(profileId: profile.id, year: 2023)) {
        case let .success(timePeriodStatistics):
            print(timePeriodStatistics)
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed loading time period statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}
