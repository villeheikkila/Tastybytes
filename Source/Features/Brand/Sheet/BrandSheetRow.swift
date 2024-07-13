import Models
import SwiftUI

struct BrandSheetRowView: View {
    let brand: Brand.JoinedSubBrands
    let onClick: (_ brand: Brand.JoinedSubBrands) -> Void

    var body: some View {
        Button(action: {
            onClick(brand)
        }, label: {
            HStack(alignment: .center) {
                BrandLogoView(brand: brand, size: 42)
                Text("\(brand.name)")
                Spacer()
            }
        })
        .listRowBackground(Color.clear)
    }
}
