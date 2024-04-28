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

        return dateRange.dates(byAdding: timePeriod.groupingInterval, using: calendar)
            .map { currentDate -> Self in
                let numberOfCheckIns: Int = switch timePeriod {
                case .year, .sixMonths:
                    checkInsPerDay.filter { checkIn in
                        calendar.isDate(checkIn.checkInDate, equalTo: currentDate, toGranularity: .month)
                    }.reduce(0) { $0 + $1.numberOfCheckIns }
                case .week, .month:
                    checkInsPerDay.first(where: { checkIn in
                        calendar.isDate(checkIn.checkInDate, inSameDayAs: currentDate)
                    })?.numberOfCheckIns ?? 0
                }
                return .init(date: currentDate, checkIns: numberOfCheckIns)
            }
    }
}
