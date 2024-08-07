import Models
import SwiftUI

struct DiscoverProductLinks: View {
    var body: some View {
        Section("discover.product.links") {
            Group {
                RouterLink(
                    Product.FeedType.trending.label,
                    systemImage: "chart.line.uptrend.xyaxis",
                    open: .screen(.productFeed(.trending))
                )
                RouterLink(
                    Product.FeedType.topRated.label,
                    systemImage: "line.horizontal.star.fill.line.horizontal",
                    open: .screen(.productFeed(.topRated))
                )
                RouterLink(
                    Product.FeedType.latest.label,
                    systemImage: "bolt.horizontal.circle",
                    open: .screen(.productFeed(.latest))
                )
            }
            .bold()
        }
        .headerProminence(.increased)
    }
}
