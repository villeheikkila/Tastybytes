import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProductListScreen: View {
    let products: [Product.Joined]

    var body: some View {
        List(products) { product in
            ProductListRowView(product: product)
        }
        .listStyle(.plain)
        .navigationTitle("product.list.navigationTitle")
    }
}
