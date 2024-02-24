import Models
import SwiftUI

@MainActor
struct CompanyBrandRow: View {
    let brand: Brand.JoinedSubBrandsProducts

    var body: some View {
        HStack(alignment: .center) {
            BrandLogo(brand: brand, size: 42)
            Text(brand.name)
            Spacer()
            Text("(\(brand.productCount.formatted()))")
        }
    }
}
