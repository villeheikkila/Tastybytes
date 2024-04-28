import Models
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

    var groupingInterval: Calendar.Component {
        switch self {
        case .week, .month:
            .day
        case .year, .sixMonths:
            .month
        }
    }

    func startOfPeriod(for date: Date, using calendar: Calendar) -> Date {
        calendar.dateInterval(of: groupingInterval, for: date)?.start ?? date
    }

    func getTimeRange(page: Int) -> ClosedRange<Date>? {
        let now = Date.now
        let calendar = Calendar.current
        switch self {
        case .week:
            let now = Date()
            if let shiftedStartDate = calendar.date(byAdding: .weekOfYear, value: page, to: now),
               let weekStart = calendar.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: shiftedStartDate)),
               let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart),
               let currentWeekStart = calendar.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
            {
                return weekStart ... weekEnd
            }
        case .month:
            if let startOfMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: now)),
               let shiftedStartOfMonth = calendar.date(byAdding: .month, value: page, to: startOfMonth),
               let endOfMonth = calendar.date(byAdding: .month, value: 1, to: shiftedStartOfMonth, wrappingComponents: false),
               let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: endOfMonth)
            {
                return shiftedStartOfMonth ... lastDayOfMonth
            }
        case .sixMonths:
            guard let shiftedDate = calendar.date(byAdding: .month, value: 6 * page, to: now) else { return nil }
            let components = calendar.dateComponents([.year, .month], from: shiftedDate)
            guard let month = components.month, let year = components.year else { return nil }
            let startMonthOfHalf = month > 6 ? 7 : 1
            if let halfYearStart = calendar.date(from: DateComponents(year: year, month: startMonthOfHalf, day: 1)),
               let halfYearEnd = calendar.date(byAdding: .month, value: 6, to: halfYearStart),
               let lastDayOfLastMonth = calendar.date(byAdding: .day, value: -1, to: halfYearEnd)
            {
                return halfYearStart ... lastDayOfLastMonth
            }
        case .year:
            if let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
               let shiftedStartOfYear = calendar.date(byAdding: .year, value: page, to: startOfYear),
               let endOfYear = calendar.date(byAdding: .year, value: 1, to: shiftedStartOfYear, wrappingComponents: false),
               let lastDayOfYear = calendar.date(byAdding: .day, value: -1, to: endOfYear)
            {
                return shiftedStartOfYear ... lastDayOfYear
            }
        }
        return nil
    }
}
