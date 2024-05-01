import Charts
import Models
import SwiftUI

@MainActor
struct CheckInsByTimeRangeChart: View {
    @Environment(Router.self) private var router
    let profile: Profile
    let checkInsTimeBuckets: [CheckInsTimeBucket]

    var body: some View {
        Chart {
            ForEach(checkInsTimeBuckets) { row in
                row.barMark
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisValueLabel()
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .onTapGesture { location in
                        onBarChartClick(at: location, proxy: proxy, geometry: geometry)
                    }
            }
        }
        .frame(height: 100)
    }

    private func onBarChartClick(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let xPosition = location.x - geometry[plotFrame].origin.x
        guard let value: String = proxy.value(atX: xPosition) else {
            return
        }
        if let timeBucket = checkInsTimeBuckets.first(where: { bucket in bucket.label == value }) {
            router.navigate(screen: .profileCheckIns(profile, .dateRange(timeBucket.dateRange)))
        }
    }
}
