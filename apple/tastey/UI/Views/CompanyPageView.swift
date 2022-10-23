import SwiftUI

struct CompanyPageView: View {
    let company: Company
    @StateObject private var viewModel = ViewModel()
    
    func getProductJoined(product: ProductJoinedCategory, subBrand: SubBrand, brand: BrandJoinedSubBrandsJoinedProduct) -> ProductJoined {
        return ProductJoined(id: product.id, name: product.name, description: product.name, subBrand: SubBrandJoinedWithBrand(id: subBrand.id, name: subBrand.name, brand: BrandJoinedWithCompany(id: brand.id, name: brand.name, brandOwner: company) ), subcategories: product.subcategories )
    }

    var body: some View {
        ScrollView {
            CardView {
                HStack {
                    Text(company.name)
                    Spacer()
                }
            }
            if let companyJoined = viewModel.companyJoined {
                ForEach(companyJoined.brands, id: \.id) { brand in
                    Section {
                        ForEach(brand.subBrands, id: \.id) {
                            subBrand in
                            ForEach(subBrand.products, id: \.id) {
                                product in
                                NavigationLink(value: ProductJoined(company: company, product: product, subBrand: subBrand, brand: brand)) {
                                    HStack {
                                        Text(joinOptionalStrings([brand.name, subBrand.name]))
                                        Text(product.name)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.all, 10)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
                    .padding([.leading, .trailing], 10)
                    }

                }
        }
        .task {
            viewModel.getInitialData(company.id)
        }
    }
}

extension CompanyPageView {
    @MainActor class ViewModel: ObservableObject {
        @Published var companyJoined: CompanyJoined?
        
        func getInitialData(_ companyId: Int) {
            Task {
                do {
                    let company = try await repository.company.getById(id: companyId)
                    print("co: \(company)")
                    DispatchQueue.main.async {
                        self.companyJoined = company
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
}
