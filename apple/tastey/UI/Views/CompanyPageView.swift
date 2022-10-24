import CachedAsyncImage
import SwiftUI

struct CompanyPageView: View {
    let company: Company
    @EnvironmentObject var currentProfile: CurrentProfile
    @EnvironmentObject var navigator: Navigator
    @StateObject private var viewModel = ViewModel()
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var showDeleteBrandConfirmationDialog = false
    
    func getProductJoined(product: ProductJoinedCategory, subBrand: SubBrand, brand: BrandJoinedSubBrandsJoinedProduct) -> ProductJoined {
        return ProductJoined(id: product.id, name: product.name, description: product.name, subBrand: SubBrandJoinedWithBrand(id: subBrand.id, name: subBrand.name, brand: BrandJoinedWithCompany(id: brand.id, name: brand.name, brandOwner: company)), subcategories: product.subcategories)
    }
    
    var body: some View {
        List {
            HStack(spacing: 20) {
                if let logoUrl = company.getLogoUrl() {
                    CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "photo")
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 52, height: 52)
                }
                VStack(spacing: 10) {
                    HStack {
                        Text(company.name)
                            .font(.title3)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    if let checkIns = viewModel.companySummary?.totalCheckIns {
                        HStack {
                            Text("Check-ins:")
                            Spacer()
                            Text(String(checkIns))
                        }
                    }
                    if let averageRating = viewModel.companySummary?.averageRating {
                        HStack {
                            Text("Average:")
                            Spacer()
                            RatingView(rating: averageRating)
                        }
                    }
                    if let currentUserAverageRating = viewModel.companySummary?.currentUserAverageRating {
                        HStack {
                            Text("Your rating:")
                            Spacer()
                            RatingView(rating: currentUserAverageRating)
                        }
                    }
                }.contextMenu {
                    if currentProfile.hasPermission(.canDeleteCompanies) {
                        Button(action: {
                            showDeleteCompanyConfirmationDialog.toggle()
                        }) {
                            Label("Delete", systemImage: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(.all, 10)
            
            if let companyJoined = viewModel.companyJoined {
                ForEach(companyJoined.brands, id: \.id) { brand in
                    Section {
                        ForEach(brand.subBrands, id: \.id) {
                            subBrand in
                            ForEach(subBrand.products, id: \.id) {
                                product in
                                NavigationLink(value: ProductJoined(company: company, product: product, subBrand: subBrand, brand: brand)) {
                                    HStack {
                                        Text(joinOptionalStrings([brand.name, subBrand.name, product.name]))
                                            .lineLimit(nil)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("\(brand.name) (\(brand.getNumberOfProducts()))")
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
            Button("Delete Company", role: .destructive, action: { viewModel.deleteCompany(company, onDelete: {
                navigator.gotoHomePage()
            }) })
        }
        .task {
            viewModel.getInitialData(company.id)
        }
    }
}

extension CompanyPageView {
    @MainActor class ViewModel: ObservableObject {
        @Published var companyJoined: CompanyJoined?
        @Published var companySummary: CompanySummary?
        
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
            
            Task {
                do {
                    let summary = try await repository.company.getSummaryById(id: companyId)
                    DispatchQueue.main.async {
                        self.companySummary = summary
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
        
        func deleteCompany(_ company: Company, onDelete: @escaping () -> Void) {
            Task {
                do {
                    try await repository.company.delete(id: company.id)
                    onDelete()
                } catch {
                    print("error while trying to delete company \(error)")
                }
            }
        }
        
        func deleteBrand(_ brand: BrandJoinedSubBrandsJoinedProduct) {
            Task {
                do {
                    try await repository.brand.delete(id: brand.id)
                    // TODO: Do not refetch the company on deletion
                    if let companyJoined = companyJoined {
                        let company = try await repository.company.getById(id: companyJoined.id)
                        DispatchQueue.main.async {
                            self.companyJoined = company
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}
