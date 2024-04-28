import Foundation
import Models

struct CheckInsTimeBucket: Identifiable {
    var id: Double { date.timeIntervalSince1970 }
    let date: Date
    let checkIns: Int

    static func getBuckets(checkInsPerDay: [CheckInsPerDay],
                           timePeriod: StatisticsTimePeriod,
                           dateRange: ClosedRange<Date>) -> [Self]
    {
        let calendar = Calendar.current
        var results = [Date: Int]()

        var currentDate = dateRange.lowerBound
        while currentDate <= dateRange.upperBound {
            let numberOfCheckIns = switch timePeriod {
            case .year, .sixMonths:
                checkInsPerDay.filter { checkIn in
                    calendar.isDate(checkIn.checkInDate, equalTo: currentDate, toGranularity: .month)
                }.reduce(0) { partialResult, checkInsPerDay in
                    partialResult + checkInsPerDay.numberOfCheckIns
                }
            case .week, .month:
                checkInsPerDay.first(where: { checkIn in
                    calendar.isDate(checkIn.checkInDate, inSameDayAs: currentDate)
                })?.numberOfCheckIns ?? 0
            }

            results[currentDate, default: 0] = numberOfCheckIns
            if let nextDate = calendar.date(byAdding: timePeriod.groupingInterval, value: 1, to: currentDate) {
                currentDate = nextDate
            }
        }
        return results.sorted(by: { $0.key < $1.key }).map { key, value in .init(date: key, checkIns: value) }
    }
}
