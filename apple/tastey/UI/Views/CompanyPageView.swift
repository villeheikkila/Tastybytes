import SwiftUI

struct CompanyPageView: View {
    let company: Company
    @EnvironmentObject var currentProfile: CurrentProfile
    @StateObject private var viewModel = ViewModel()
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var showDeleteBrandConfirmationDialog = false

    func getProductJoined(product: ProductJoinedCategory, subBrand: SubBrand, brand: BrandJoinedSubBrandsJoinedProduct) -> ProductJoined {
        return ProductJoined(id: product.id, name: product.name, description: product.name, subBrand: SubBrandJoinedWithBrand(id: subBrand.id, name: subBrand.name, brand: BrandJoinedWithCompany(id: brand.id, name: brand.name, brandOwner: company)), subcategories: product.subcategories)
    }

    var body: some View {
        List {
            HStack {
                Text(company.name)
                Spacer()
            }
            .contextMenu {
                if currentProfile.hasPermission(.canDeleteCompanies) {
                    Button(action: {
                        showDeleteCompanyConfirmationDialog.toggle()
                    }) {
                        Label("Delete", systemImage: "trash.fill")
                            .foregroundColor(.red)
                    }
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
                    } header: {
                        HStack {
                            Text(brand.name)
                            Spacer()
                            if currentProfile.hasPermission(.canDeleteBrands) {
                                Button(action: {
                                    showDeleteBrandConfirmationDialog.toggle()
                                }) {
                                    Image(systemName: "x.square")
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)
                    .confirmationDialog("delete_brand",
                        isPresented: $showDeleteBrandConfirmationDialog
                    ) {
                        Button("Delete Brand", role: .destructive, action: { viewModel.deleteBrand(brand) })
                    }
                    
                }
            }
        }
        .confirmationDialog("delete_company",
            isPresented: $showDeleteCompanyConfirmationDialog
        ) {
            Button("Delete Company", role: .destructive, action: { viewModel.deleteCompany(company) })
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
                    DispatchQueue.main.async {
                        self.companyJoined = company
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }

        func deleteCompany(_ company: Company) {
            Task {
                do {
                    try await repository.company.delete(id: company.id)
                } catch {
                    print(error)
                }
            }
        }
        
        func deleteBrand(_ brand: BrandJoinedSubBrandsJoinedProduct) {
            Task {
                do {
                    try await repository.brand.delete(id: brand.id)
                } catch {
                    print(error)
                }
            }
        }
    }
}
