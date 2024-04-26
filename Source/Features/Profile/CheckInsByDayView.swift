import Charts
import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

extension StatisticsTimePeriod {
    var label: LocalizedStringKey {
        switch self {
        case .sixMonths:
            "timePeriod.abbreviated.sixMonths"
        case .year:
            "timePeriod.abbreviated.year"
        case .month:
            "timePeriod.abbreviated.month"
        case .week:
            "timePeriod.abbreviated.week"
        }
    }

    func xAxisLabel(_ date: Date) -> String {
        switch self {
        case .week:
            return date.formatted(.dateTime.weekday(.abbreviated))
        case .month:
            let calendar = Calendar.current
            return calendar.component(.day, from: date).formatted()
        case .year, .sixMonths:
            return date.formatted(.dateTime.month(.abbreviated))
        }
    }

    func groupingInterval() -> Calendar.Component {
        switch self {
        case .week, .month:
            .day
        case .year, .sixMonths:
            .month
        }
    }

    func startOfPeriod(for date: Date, using calendar: Calendar) -> Date {
        calendar.dateInterval(of: groupingInterval(), for: date)?.start ?? date
    }
}

@MainActor
struct CheckInsByDayView: View {
    private let logger = Logger(category: "CheckInsByDayView")
    @Environment(Repository.self) private var repository
    @State private var isLoading = false
    @State private var checkInsPerDay = [CheckInsPerDay]()
    @State private var timePeriod: StatisticsTimePeriod = .week

    @State private var page = 0
    @State private var dateRange: ClosedRange<Date> = Date.now ... Date.now

    let profile: Profile

    var checkInsInRange: [CheckInsPerDay] {
        checkInsPerDay.filter { checkIn in
            dateRange.contains(checkIn.checkInDate)
        }
    }

    var body: some View {
        Section {
            DateRangePicker(timePeriod: $timePeriod, dateRange: $dateRange)
            CheckInsByDayChart(checkInsPerDay: checkInsInRange, timePeriod: timePeriod, dateRange: dateRange)
            TimePeriodStatisticSegmentView(checkInsPerDay: checkInsInRange)
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
        switch await repository.profile.getNumberOfCheckInsByDay(.init(profileId: profile.id)) {
        case let .success(checkInsPerDay):
            self.checkInsPerDay = checkInsPerDay
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed loading time period statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}

struct CheckInsByDayChart: View {
    let checkInsPerDay: [CheckInsPerDay]
    let timePeriod: StatisticsTimePeriod
    let dateRange: ClosedRange<Date>

    var groupedCheckIns: [Date: Int] {
        let calendar = Calendar.current
        return checkInsPerDay.reduce(into: [Date: Int]()) { result, checkIn in
            let startOfPeriod = timePeriod.startOfPeriod(for: checkIn.checkInDate, using: calendar)
            result[startOfPeriod, default: 0] += checkIn.numberOfCheckIns
        }
    }

    var body: some View {
        Chart {
            ForEach(checkInsPerDay) { row in
                BarMark(
                    x: .value("checkInsByDayChart.axisLabel.date", timePeriod.xAxisLabel(row.checkInDate)),
                    y: .value("checkInsByDayChart.axisLabel.checkIns", row.numberOfCheckIns)
                )
            }
        }
    }
}

struct DateRangePicker: View {
    @State private var page = 0
    @Binding var timePeriod: StatisticsTimePeriod
    @Binding var dateRange: ClosedRange<Date>

    private var dateRangeString: String {
        "\(dateRange.lowerBound.formatted(.dateTime.day().month().year(.twoDigits))) - \(dateRange.upperBound.formatted(.dateTime.day().month().year(.twoDigits)))"
    }

    var body: some View {
        Picker("checkIn.statistics.timePeriod.segment.picker", selection: $timePeriod) {
            ForEach(StatisticsTimePeriod.allCases, id: \.self) { segment in
                Text(segment.label)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, -8)
        HStack {
            PageButton(direction: .decrement, page: $page)
            Spacer()
            Text(dateRangeString)
            Spacer()
            PageButton(direction: .increment, page: $page)
        }
        .onChange(of: timePeriod) {
            page = 0
        }
        .onChange(of: page, initial: true) { _, _ in
            let now = Date.now
            switch timePeriod {
            case .week:
                let now = Date()
                guard let shiftedStartDate = Calendar.current.date(byAdding: .weekOfYear, value: page, to: now),
                      let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: shiftedStartDate))
                else {
                    return
                }
                guard let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) else {
                    return
                }
                guard let currentWeekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())),
                      let endOfCurrentWeek = Calendar.current.date(byAdding: .day, value: 6, to: currentWeekStart)
                else {
                    return
                }
                let newEndDate = min(weekEnd, endOfCurrentWeek)
                dateRange = weekStart ... newEndDate
            case .month:
                guard let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: now)),
                      let shiftedStartOfMonth = Calendar.current.date(byAdding: .month, value: page, to: startOfMonth),
                      let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: shiftedStartOfMonth, wrappingComponents: false),
                      let lastDayOfMonth = Calendar.current.date(byAdding: .day, value: -1, to: endOfMonth)
                else {
                    return
                }
                let newEndMonthDate = min(lastDayOfMonth, now)
                dateRange = shiftedStartOfMonth ... newEndMonthDate
            case .sixMonths:
                guard let shiftedDate = Calendar.current.date(byAdding: .month, value: 6 * page, to: now) else { return }
                let components = Calendar.current.dateComponents([.year, .month], from: shiftedDate)
                guard let month = components.month else { return }
                guard let year = components.year else { return }
                let startMonthOfHalf = month > 6 ? 7 : 1
                guard let halfYearStart = Calendar.current.date(from: DateComponents(year: year, month: startMonthOfHalf, day: 1)) else { return }
                guard let halfYearEnd = Calendar.current.date(byAdding: .month, value: 6, to: halfYearStart),
                      let adjustedDate = Calendar.current.date(byAdding: .day, value: -1, to: halfYearEnd) else { return }
                dateRange = halfYearStart ... adjustedDate
                print("Date range from \(halfYearStart) to \(adjustedDate)")
            case .year:
                guard let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: now)),
                      let shiftedStartOfYear = Calendar.current.date(byAdding: .year, value: page, to: startOfYear),
                      let endOfYear = Calendar.current.date(byAdding: .year, value: 1, to: shiftedStartOfYear, wrappingComponents: false),
                      let lastDayOfYear = Calendar.current.date(byAdding: .day, value: -1, to: endOfYear)
                else {
                    return
                }
                let newEndYearDate = min(lastDayOfYear, now)
                dateRange = shiftedStartOfYear ... newEndYearDate
            }
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
}

struct PageButton: View {
    enum Direction {
        case increment
        case decrement

        var systemImage: String {
            switch self {
            case .decrement:
                "chevron.left"
            case .increment:
                "chevron.right"
            }
        }

        var label: LocalizedStringKey {
            switch self {
            case .decrement: "timePeriod.previous"
            case .increment: "timePeriod.next"
            }
        }
    }

    @State private var isPressed = false
    let direction: Direction
    @Binding var page: Int

    public var body: some View {
        Button(direction.label, systemImage: direction.systemImage, action: {
            let newPage = page + (direction == .decrement ? -1 : 1)
            guard newPage <= 0 else { return }
            page = newPage
        })
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .symbolEffect(.bounce.down, value: isPressed)
    }
}
