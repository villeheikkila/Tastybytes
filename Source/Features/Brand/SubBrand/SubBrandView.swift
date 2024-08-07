import Models
import SwiftUI

struct SubBrandView: View {
    let brand: BrandProtocol
    let subBrand: SubBrandProtocol

    init(brand: BrandProtocol, subBrand: SubBrandProtocol) {
        self.brand = brand
        self.subBrand = subBrand
    }

    init(subBrand: SubBrand.JoinedBrand) {
        brand = subBrand.brand
        self.subBrand = subBrand
    }

    init(subBrand: SubBrand.Detailed) {
        brand = subBrand.brand
        self.subBrand = subBrand
    }

    var body: some View {
        VStack(alignment: .leading) {
            BrandView(brand: brand)
                .verificationBadgeVisibility(.hidden)
            HStack(alignment: .center) {
                Text(subBrand.name ?? "-")
                VerifiedBadgeView(verifiable: brand)
            }
        }
    }
}
