import Models
import SwiftUI

struct BrandEntityView: View {
    let brand: Brand.JoinedSubBrandsProductsCompany

    var body: some View {
        HStack {
            BrandLogo(brand: brand, size: 40)
            VStack(alignment: .leading) {
                Text(brand.brandOwner.name)
                Text(brand.name)
            }
        }
    }
}
