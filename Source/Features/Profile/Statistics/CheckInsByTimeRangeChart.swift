import Charts
import Models
import SwiftUI

struct CheckInsByTimeRangeChart: View {
    let checkInsPerDay: [CheckInsPerDay]
    let timePeriod: StatisticsTimePeriod
    let dateRange: ClosedRange<Date>

    var groupedCheckIns: [CheckInsTimeBucket] {
        CheckInsTimeBucket.getBuckets(checkInsPerDay: checkInsPerDay, timePeriod: timePeriod, dateRange: dateRange)
    }

    var body: some View {
        Chart {
            ForEach(groupedCheckIns) { row in
                BarMark(
                    x: .value("checkInsByDayChart.axisLabel.date", timePeriod.xAxisLabel(row.date)),
                    y: .value("checkInsByDayChart.axisLabel.checkIns", row.checkIns)
                )
            }
        }
    }
}
