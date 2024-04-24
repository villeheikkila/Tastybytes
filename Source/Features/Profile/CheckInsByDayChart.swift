import Charts
import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

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
    @State private var shiftBy = 0
    @State private var dateRange: ClosedRange<Date> = {
        let endDate = Date.now
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        return startDate ... endDate
    }()

    let profile: Profile

    var checkInsInRange: [CheckInsPerDay] {
        timePeriodStatistics.filter { checkIn in
            dateRange.contains(checkIn.checkInDate)
        }
    }

    private func shiftDateRange(byWeeks weeks: Int) {
        guard let newStartDate = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: dateRange.lowerBound),
              let newEndDate = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: dateRange.upperBound)
        else {
            return
        }
        dateRange = newStartDate ... newEndDate
    }

    private func shiftDateRange(byMonths months: Int) {
        guard let newStartDate = Calendar.current.date(byAdding: .month, value: months, to: dateRange.lowerBound),
              let newEndDate = Calendar.current.date(byAdding: .month, value: months, to: dateRange.upperBound)
        else {
            return
        }
        dateRange = newStartDate ... newEndDate
    }

    private func shiftDateRange(byYears year: Int) {
        guard let newStartDate = Calendar.current.date(byAdding: .year, value: year, to: dateRange.lowerBound),
              let newEndDate = Calendar.current.date(byAdding: .year, value: year, to: dateRange.upperBound)
        else {
            return
        }
        dateRange = newStartDate ... newEndDate
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
            Text(dateRange)
            Stepper("Adjust Value", value: $shiftBy, in: 0 ... 100)
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
        .onChange(of: shiftBy) { _, _ in
            switch timePeriod {
            case .week:
                shiftDateRange(byWeeks: -shiftBy)
            case .month:
                shiftDateRange(byMonths: -shiftBy)
            case .year:
                shiftDateRange(byYears: -shiftBy)
            case .all:
                shiftDateRange(byWeeks: -shiftBy)
            }
        }
    }

    func loadStatisticsForTimePeriod() async {
        guard isLoading == false else { return }
        isLoading = true
        switch await repository.profile.getNumberOfCheckInsByDay(.init(profileId: profile.id)) {
        case let .success(timePeriodStatistics):
            self.timePeriodStatistics = timePeriodStatistics
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed loading time period statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}
