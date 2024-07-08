import Models
import SwiftUI

struct SubBrandEntityView: View {
    @Environment(\.verificationBadgeVisibility) private var verificationBadgeVisibility
    let brand: BrandProtocol
    let subBrand: SubBrandProtocol

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
