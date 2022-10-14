import SwiftUI

struct ProductCardView: View {
    let product: ProductResponse

    var body: some View {
        VStack {
            Text(product.sub_brands.brands.name)
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.white)
            if product.sub_brands.name != "" {
                Text(product.sub_brands.name)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.primary)
            }
            Text(product.name)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(.primary)
            Text(product.sub_brands.brands.companies.name)
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.secondary)
        }
        .padding(.all, 10)
        .frame(maxWidth: .infinity, alignment: .center)
        .cornerRadius(5)
    }
}
