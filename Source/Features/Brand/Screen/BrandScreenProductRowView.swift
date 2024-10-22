import Components

import Extensions
import Models
import Logging
import Repositories
import SwiftUI

struct BrandScreenProductRowView: View {
    let product: Product.Joined

    var body: some View {
        RouterLink(open: .screen(.product(product.id))) {
            ProductView(product: product)
                .padding(2)
                .productLogoLocation(.left)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}
