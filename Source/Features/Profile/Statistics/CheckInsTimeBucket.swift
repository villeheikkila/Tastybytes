import Charts
import Foundation
import Models

struct CheckInsTimeBucket: Identifiable {
    var id: String { "\(dateRange.lowerBound.timeIntervalSince1970)-\(dateRange.upperBound.timeIntervalSince1970)" }
    let dateRange: ClosedRange<Date>
    let label: String
    let checkIns: Int

    var barMark: BarMark {
        BarMark(
            x: .value("checkInsByDayChart.axisLabel.date", label),
            y: .value("checkInsByDayChart.axisLabel.checkIns", checkIns)
        )
    }

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
                let label = timePeriod.xAxisLabel(currentDate)

                let dateRange = timePeriod.getBucketRange(date: currentDate) ?? dateRange
                return .init(dateRange: dateRange, label: label, checkIns: numberOfCheckIns)
            }
    }
}
