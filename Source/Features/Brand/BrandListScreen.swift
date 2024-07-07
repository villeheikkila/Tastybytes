import Models
import SwiftUI

struct BrandListScreen: View {
    let brands: [Brand]

    var body: some View {
        List(brands) { brand in
            BrandEntityView(brand: brand)
        }
        .listStyle(.plain)
        .navigationTitle("brand.list.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
