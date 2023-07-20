import Charts
import SwiftUI

struct RatingChartView: View {
    @Environment(Router.self) private var router
    @State private var selection: String?
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
            .chartXSelection(value: $selection)
            .onChange(of: selection) { _, newValue in
                if let newValue, let rating = Double(newValue) {
                    router.navigate(screen: .profileProductsByFilter(profile, Product.Filter(rating: rating)))
                }
            }
            .frame(height: 100)
        }
    }
}
