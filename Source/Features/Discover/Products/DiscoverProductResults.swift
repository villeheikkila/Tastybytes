
import Models
import Logging
import Repositories
import SwiftUI

struct DiscoverProductResults: View {
    @Environment(ProfileModel.self) private var profileModel
    let products: [Product.Joined]
    @Binding var barcode: Barcode?
    let showContentUnavailableView: Bool
    let searchKey: DiscoverScreen.SearchKey?
    let searchResultKey: DiscoverScreen.SearchKey?

    var body: some View {
        if products.isEmpty, searchKey == nil {
            DiscoverProductLinks()
        } else {
            ForEach(products) { product in
                DiscoverProductRow(product: product, barcode: $barcode)
                    .id(product.id)
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        0
                    }
            }
        }
    }
}
