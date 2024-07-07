import Models
import SwiftUI

struct SubBrandListScreen: View {
    let subBrands: [SubBrand.JoinedBrand]

    var body: some View {
        List(subBrands) { subBrand in
            SubBrandEntityView(brand: subBrand.brand, subBrand: subBrand)
        }
        .listStyle(.plain)
        .navigationTitle("subBrand.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
