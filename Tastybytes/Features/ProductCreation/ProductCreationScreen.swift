import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import SwiftUI

struct ProductCreationScreen: View {
    @State private var selection: Section = .brand
    @State var brand: Brand.JoinedSubBrands?

    var body: some View {
        TabView(selection: $selection) {
            ProductCreationBrandSection(section: $selection)
                .tag(Section.brand)
            ProductCreationProductSection(section: $selection)
                .tag(Section.company)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
}

struct MockProduct {
    let brandOwner: String
    let brandName: String
}

struct ProductCreationBrandSection: View {
    private let logger = Logger(category: "ProductCreationBrandSection")
    @State private var searchTerm: String = ""
    @Binding var section: ProductCreationScreen.Section

    let products = [
        MockProduct(brandOwner: "Owner 2", brandName: "Brand 1"),
        MockProduct(brandOwner: "Owner 2", brandName: "Brand 2"),
        MockProduct(brandOwner: "Owner 3", brandName: "Brand 3"),
    ]

    var filteredProducts: [MockProduct] {
        products.filter { $0.brandName.contains(searchTerm) }
    }

    var body: some View {
        List(filteredProducts, id: \.brandName) { product in
            BrandRow(product: product)
                .onTapGesture {
                    section = .company
                }
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Brand")
    }
}

struct ProductCreationProductSection: View {
    private let logger = Logger(category: "ProductCreationBrandSection")
    @State private var searchTerm: String = ""
    @Binding var section: ProductCreationScreen.Section

    let products = [
        MockProduct(brandOwner: "Owner 2", brandName: "Brand 1"),
        MockProduct(brandOwner: "Owner 2", brandName: "Brand 2"),
        MockProduct(brandOwner: "Owner 3", brandName: "Brand 3"),
    ]

    var filteredProducts: [MockProduct] {
        products.filter { $0.brandName.contains(searchTerm) }
    }

    var body: some View {
        List(filteredProducts, id: \.brandName) { product in
            BrandRow(product: product)
                .onTapGesture {
                    section = .company
                }
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Product")
    }
}

struct BrandRow: View {
    let product: MockProduct

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.brandOwner)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(product.brandName)
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: .gray, radius: 2, x: 0.0, y: 2)
    }
}

extension ProductCreationScreen {
    enum Section: Int, Identifiable, Hashable {
        case brand, company

        var id: Int {
            rawValue
        }
    }
}

#Preview {
    ProductCreationScreen()
}
