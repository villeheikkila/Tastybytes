import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack {
            Text(product.subBrand.brand.name)
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.white)
            if product.subBrand.name != "" {
                Text(product.subBrand.name)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.primary)
            }
            Text(product.name)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(.primary)
            Text(product.subBrand.brand.company.name)
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.secondary)
        }
        .padding(.all, 10)
        .frame(maxWidth: .infinity, alignment: .center)
        .cornerRadius(5)
    }
}
