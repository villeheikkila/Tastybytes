import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI
import Charts

@MainActor
struct CheckInsByDayChart: View {
    public enum TimePeriod: String, CaseIterable, Sendable {
        case week, month, year
    }

    
    private let logger = Logger(category: "TimePeriodStatisticView")
    @Environment(Repository.self) private var repository
    @State private var timePeriod: TimePeriodStatistic.TimePeriod = .week
    @State private var isLoading = false
    @State private var timePeriodStatistics = [CheckInsPerDay]()
    @State private var startDate: Date
    @State private var endDate: Date

    init(profile: Profile) {
        self.profile = profile
        self.startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date.now) ?? Date.now
        self.endDate = Date.now
        print("start date: \(startDate)")
        print("end date: \(endDate)")

    }

    let profile: Profile
    
    var checkInsInRange: [CheckInsPerDay] {
        timePeriodStatistics.filter { checkIn in
            (checkIn.checkInDate >= startDate) && (checkIn.checkInDate <= endDate)
        }
    }

    var body: some View {
        Section {
            Picker("checkIn.statistics.timePeriod.segment.picker", selection: $timePeriod) {
                ForEach(TimePeriodStatistic.TimePeriod.allCases, id: \.self) { segment in
                    Text(segment.label)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, -8)
            Text("Average")
            Text(startDate...endDate)
            Chart {
                ForEach(checkInsInRange) { row in
                    BarMark(
                        x: .value("Date", row.checkInDate),
                        y: .value("Check-ins", row.numberOfCheckIns)
                    )
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .task {
            await loadStatisticsForTimePeriod()
        }
        .onChange(of: timePeriod) { _, newValue in
            switch timePeriod {
            case .week:
                self.startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date.now) ?? Date.now
            case .month:
                self.startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date.now) ?? Date.now
            case .year:
                self.startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date.now) ?? Date.now
            case .all:
                self.startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date.now) ?? Date.now
            }
            self.endDate = Date.now
        }
    }

    func loadStatisticsForTimePeriod() async {
        guard isLoading == false else { return }
        isLoading = true
        switch await repository.profile.getCheckInsPerDayForYear(.init(profileId: profile.id, year: 2024)) {
        case let .success(timePeriodStatistics):
            self.timePeriodStatistics = timePeriodStatistics
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed loading time period statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}

