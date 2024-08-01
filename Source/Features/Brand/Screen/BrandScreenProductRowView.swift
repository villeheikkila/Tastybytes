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
            ProductEntityView(
                product: product,
                extras: [.logoOnLeft, .rating, .checkInCheck],
                isCheckedIn: product.isCheckedInByCurrentUser,
                averageRating: product.averageRating
            )
            .padding(2)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            0
        }
    }
}
