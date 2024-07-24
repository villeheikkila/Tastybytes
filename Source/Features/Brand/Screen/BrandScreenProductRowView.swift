import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct BrandScreenProductRowView: View {
    let product: Product.Joined

    var body: some View {
        RouterLink(open: .screen(.product(product))) {
            ProductEntityView(product: product, extras: [.logoOnLeft])
                .padding(2)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}
