
import Models
import SwiftUI

struct BrandView: View {
    let brandOwner: Company.Saved?
    let brand: BrandProtocol

    init(brand: Brand.JoinedSubBrandsProductsCompany) {
        self.brand = brand
        brandOwner = brand.brandOwner
    }

    init(brand: BrandProtocol) {
        self.brand = brand
        brandOwner = nil
    }

    var body: some View {
        HStack {
            BrandLogoView(brand: brand, size: 40)
            VStack(alignment: .leading) {
                if let brandOwner {
                    Text(brandOwner.name)
                }
                HStack {
                    Text(brand.name)
                    Spacer()
                    VerifiedBadgeView(verifiable: brand)
                }
            }
        }
    }
}
