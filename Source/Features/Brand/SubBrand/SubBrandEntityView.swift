import Models
import SwiftUI

struct SubBrandEntityView: View {
    @Environment(\.verificationBadgeVisibility) private var verificationBadgeVisibility
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

    var body: some View {
        VStack(alignment: .leading) {
            BrandEntityView(brand: brand)
                .verificationBadgeVisibility(.hidden)
            HStack(alignment: .center) {
                Text(subBrand.name ?? "-")
                if verificationBadgeVisibility == .visible, subBrand.isVerified {
                    VerifiedBadgeView()
                }
            }
        }
    }
}
