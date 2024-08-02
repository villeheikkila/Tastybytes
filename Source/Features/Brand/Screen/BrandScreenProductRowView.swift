import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct BrandScreenProductRowView: View {
    let product: Product.Joined

    var body: some View {
        RouterLink(open: .screen(.product(product.id))) {
            ProductEntityView(product: product)
                .padding(2)
                .productLogoLocation(.left)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}
