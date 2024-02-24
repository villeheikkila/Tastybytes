import Charts
import Models
import SwiftUI
import TipKit

@MainActor
struct RatingChartView: View {
    @Environment(Router.self) private var router
    @State private var selection: String?
    let profile: Profile
    let profileSummary: ProfileSummary?

    var ratings: [KeyPath<ProfileSummary, Int>] = [
        \.rating1,
        \.rating2,
        \.rating3,
        \.rating4,
        \.rating5,
        \.rating6,
        \.rating7,
        \.rating8,
        \.rating9,
        \.rating10,
    ]

    var body: some View {
        Section {
            Chart {
                ForEach(Array(0 ..< ratings.count), id: \.self) { index in
                    let rating = if let profileSummary {
                        profileSummary[keyPath: ratings[index]]
                    } else {
                        0
                    }

                    BarMark(
                        x: .value("ratingChart.rating.label", (Double(index) / 2.0 + 0.5).formatted(.number)),
                        y: .value("ratingChart.value.label", rating)
                    )
                }
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
        .popoverTip(RatingChartTip())
    }
}

struct RatingChartTip: Tip {
    static let appOpenedCount = Event(id: "appOpenedCount")

    var rules: [Rule] {
        #Rule(Self.appOpenedCount) { $0.donations.count >= 5 }
    }

    var title: Text {
        Text("ratingChart.tip.title")
    }

    var message: Text? {
        Text("ratingChart.tip.message")
    }

    var asset: Image? {
        Image(systemName: "star.leadinghalf.filled")
    }
}
