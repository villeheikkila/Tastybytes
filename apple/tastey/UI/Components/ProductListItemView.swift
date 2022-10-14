import SwiftUI

struct ProductListItemView: View {
    let product: Product

    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(product.subcategories.first?.name ?? "").font(.system(size: 12, weight: .bold, design: .default))
            HStack {
                Text(product.subBrand.brand.name).font(.headline)
                    .font(.system(size: 18, weight: .bold, design: .default))

                if product.subBrand.name != "" {
                    Text(product.subBrand.name).font(.headline)
                        .font(.system(size: 18, weight: .bold, design: .default))
                }
                Text(product.name).font(.headline).font(.system(size: 18, weight: .bold, design: .default))
            }
            Text(product.subBrand.brand.company.name).font(.system(size: 12, design: .default))
            HStack {
                ForEach(product.subcategories, id: \.id) { subcategory in
                    ChipView(title: subcategory.name)
                }
            }.padding(.top, 5)
        }
    }
}
