import Models
import SwiftUI

struct CompanyBrandRowView: View {
    let brand: Brand.JoinedSubBrandsProducts

    var body: some View {
        HStack(alignment: .center) {
            BrandLogoView(brand: brand, size: 42)
            Text(brand.name)
            Spacer()
            Text("(\(brand.productCount.formatted()))")
        }
    }
}
