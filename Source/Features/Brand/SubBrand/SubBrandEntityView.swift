import Models
import SwiftUI

struct SubBrandEntityView: View {
    let brand: BrandProtocol
    let subBrand: SubBrandProtocol

    var body: some View {
        VStack(alignment: .leading) {
            Text(brand.name)
            Text(subBrand.name ?? "-")
        }
    }
}
