import Charts
import SwiftUI

struct RatingChartView: View {
    @Environment(Router.self) private var router
    let profile: Profile
    let profileSummary: ProfileSummary?

    var body: some View {
        Section {
            Chart {
                BarMark(
                    x: .value("Rating", "0.5"),
                    y: .value("Value", profileSummary?.rating1 ?? 0)
                )

                BarMark(
                    x: .value("Rating", "1"),
                    y: .value("Value", profileSummary?.rating2 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "1.5"),
                    y: .value("Value", profileSummary?.rating3 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "2"),
                    y: .value("Value", profileSummary?.rating4 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "2.5"),
                    y: .value("Value", profileSummary?.rating5 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "3"),
                    y: .value("Value", profileSummary?.rating6 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "3.5"),
                    y: .value("Value", profileSummary?.rating7 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "4"),
                    y: .value("Value", profileSummary?.rating8 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "4.5"),
                    y: .value("Value", profileSummary?.rating9 ?? 0)
                )
                BarMark(
                    x: .value("Rating", "5"),
                    y: .value("Value", profileSummary?.rating10 ?? 0)
                )
            }
            .chartLegend(.hidden)
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisValueLabel()
                }
            }
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
    }

    private func updateSelectedRating(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let xPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        guard let value: String = proxy.value(atX: xPosition), let rating = Double(value) else {
            return
        }
        router.navigate(screen: .profileProductsByFilter(profile, Product.Filter(rating: rating)))
    }
}
