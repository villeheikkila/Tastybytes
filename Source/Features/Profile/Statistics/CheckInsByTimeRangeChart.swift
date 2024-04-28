import Charts
import Models
import SwiftUI

@MainActor
struct CheckInsByTimeRangeChart: View {
    @Environment(Router.self) private var router
    @State private var selection: String?
    let profile: Profile
    let checkInsPerDay: [CheckInsPerDay]
    let timePeriod: StatisticsTimePeriod
    let dateRange: ClosedRange<Date>

    var groupedCheckIns: [CheckInsTimeBucket] {
        CheckInsTimeBucket.getBuckets(checkInsPerDay: checkInsPerDay, timePeriod: timePeriod, dateRange: dateRange)
    }

    var body: some View {
        Chart {
            ForEach(groupedCheckIns) { row in
                row.barMark
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisValueLabel()
            }
        }
        .chartXSelection(value: $selection)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .onTapGesture { location in
                        updateSelectedRating(at: location,
                                             proxy: proxy,
                                             geometry: geometry)
                    }
            }
        }
        .frame(height: 100)
    }

    private func updateSelectedRating(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let xPosition = location.x - geometry[plotFrame].origin.x
        guard let value: String = proxy.value(atX: xPosition) else {
            return
        }

        if let timeBucket = groupedCheckIns.first(where: { checkIn in checkIn.label == value }) {
            router.navigate(screen: .profileCheckIns(profile, timeBucket.dateRange))
        }
    }
}
