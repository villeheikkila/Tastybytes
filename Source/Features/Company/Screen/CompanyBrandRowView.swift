import Models
import SwiftUI

struct CompanyBrandRowView: View {
    let brand: Brand.Saved

    var body: some View {
        HStack(alignment: .center) {
            BrandLogoView(brand: brand, size: 42)
            Text(brand.name)
            Spacer()
            if let productCount = brand.productCount {
                Text("(\(productCount.formatted()))")
            }
        }
    }
}
