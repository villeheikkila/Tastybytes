import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct DiscoverProductResults: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(Router.self) private var router
    let products: [Product.Joined]
    @Binding var barcode: Barcode?
    let showContentUnavailableView: Bool
    let searchKey: DiscoverScreen.SearchKey?
    let searchResultKey: DiscoverScreen.SearchKey?

    private var showAddProductViewRow: Bool {
        searchResultKey != nil && searchKey == searchResultKey && !showContentUnavailableView && profileEnvironmentModel
            .hasPermission(.canCreateProducts)
    }

    var body: some View {
        if barcode != nil, !showContentUnavailableView {
            DiscoverProductAssignBarcode(isEmpty: products.isEmpty, barcode: $barcode)
        }

        if products.isEmpty, searchKey == nil {
            DiscoverProductLinks()
        } else {
            ForEach(products) { product in
                DiscoverProductRow(product: product, barcode: $barcode)
                    .id(product.id)
            }
        }

        if showAddProductViewRow {
            DiscoverProductAddNew(barcode: $barcode)
        }
    }
}
