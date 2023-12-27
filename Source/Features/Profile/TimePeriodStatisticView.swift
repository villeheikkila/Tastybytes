import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct TimePeriodStatisticView: View {
    private let logger = Logger(category: "TimePeriodStatisticView")
    @State private var timePeriod: TimePeriodStatistic.TimePeriod = .week

    let profile: Profile

    var body: some View {
        Section("Check-ins") {
            Picker("Time Period", selection: $timePeriod) {
                ForEach(TimePeriodStatistic.TimePeriod.allCases, id: \.self) { segment in
                    Text(segment.label)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, -8)
            TimePeriodStatisticSegmentView(profile: profile, timePeriod: timePeriod)
        }
        .headerProminence(.increased)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

struct TimePeriodStatisticSegmentView: View {
    private let logger = Logger(category: "TimePeriodStatisticSegmentView")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var timePeriodStatistics: TimePeriodStatistic?
    @State private var isLoading = false
    @State private var alertError: AlertError?

    let profile: Profile
    let timePeriod: TimePeriodStatistic.TimePeriod

    var body: some View {
        VStack {
            if let checkIns = timePeriodStatistics?.checkIns {
                HStack {
                    Text("Check-ins")
                    Spacer()
                    Text(String(checkIns))
                }
                .font(.caption)
                .bold()
            }
            if let newUniqueProducts = timePeriodStatistics?.newUniqueProducts {
                HStack {
                    Text("New Products")
                    Spacer()
                    Text(String(newUniqueProducts))
                }
                .font(.caption)
                .bold()
            }
        }
        .alertError($alertError)
        .task(id: timePeriod) {
            await loadStatisticsForTimePeriod(timePeriod: timePeriod)
        }
    }

    func loadStatisticsForTimePeriod(timePeriod: TimePeriodStatistic.TimePeriod) async {
        guard isLoading == false else { return }
        isLoading = true
        switch await repository.profile.getTimePeriodStatistics(userId: profile.id, timePeriod: timePeriod) {
        case let .success(timePeriodStatistics):
            withAnimation {
                self.timePeriodStatistics = timePeriodStatistics
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed loading time period statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}
