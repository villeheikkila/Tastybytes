import CachedAsyncImage
import SwiftUI

struct CompanyScreenView: View {
    let company: Company
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var routeManager: RouteManager
    @StateObject private var viewModel = ViewModel()
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var showDeleteBrandConfirmationDialog = false
    
    func getProductJoined(product: ProductJoinedCategory, subBrand: SubBrand, brand: BrandJoinedSubBrandsJoinedProduct) -> ProductJoined {
        return ProductJoined(id: product.id, name: product.name, description: product.name, subBrand: SubBrandJoinedWithBrand(id: subBrand.id, name: subBrand.name, brand: BrandJoinedWithCompany(id: brand.id, name: brand.name, brandOwner: company)), category: product.category, subcategories: product.subcategories, barcodes: [])
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
                    ShareLink("Share", item: createLinkToScreen(.company(id: company.id)))
                    
                    if profileManager.hasPermission(.canDeleteCompanies) {
                        Button(action: {
                            showDeleteCompanyConfirmationDialog.toggle()
                        }) {
                            Label("Delete", systemImage: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: {
                        viewModel.setActiveSheet(.editSuggestion)
                    }) {
                        Label("Edit Suggestion", systemImage: "pencil")
                    }
                    
                }
            }
            .padding(.all, 10)
            .sheet(item: $viewModel.activeSheet) { sheet in
                switch sheet {
                case .editSuggestion:
                    companyEditSuggestion
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
                            if profileManager.hasPermission(.canDeleteBrands) {
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
                routeManager.gotoHomePage()
            }) })
        }
        .task {
            viewModel.getInitialData(company.id)
        }
    }
    
    var companyEditSuggestion: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.newCompanyNameSuggestion)
                Button("Send edit suggestion") {
                    viewModel.sendCompanyEditSuggestion()
                }
                .disabled(!validateStringLength(str: viewModel.newCompanyNameSuggestion, type: .normal))
            } header: {
                Text("What should the company be called?")
            }
        }
    }
}

extension CompanyScreenView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case editSuggestion
    }
    
    @MainActor class ViewModel: ObservableObject {
        @Published var companyJoined: CompanyJoined?
        @Published var companySummary: CompanySummary?
        @Published var activeSheet: Sheet?
        
        @Published var newCompanyNameSuggestion = ""
        
        func setActiveSheet(_ sheet: Sheet) {
                self.activeSheet = sheet
        }
        
        func sendCompanyEditSuggestion() {
            
        }
        
        func getInitialData(_ companyId: Int) {
            Task {
                switch await repository.company.getJoinedById(id: companyId) {
                case let .success(company):
                    await MainActor.run {
                        self.companyJoined = company
                    }
                case let .failure(error):
                    print(error)
                }
            }
            
            Task {
                switch await repository.company.getSummaryById(id: companyId) {
                case let .success(summary):
                    await MainActor.run {
                        self.companySummary = summary
                    }
                case let .failure(error):
                    print("error: \(error)")
                }
            }
        }
        
        func deleteCompany(_ company: Company, onDelete: @escaping () -> Void) {
            Task {
                switch await repository.company.delete(id: company.id) {
                case .success():
                    onDelete()
                case let .failure(error):
                    print(error)
                }
            }
        }
        
        func deleteBrand(_ brand: BrandJoinedSubBrandsJoinedProduct) {
            Task {
                switch await repository.brand.delete(id: brand.id) {
                case .success():
                    // TODO: Do not refetch the company on deletion
                    if let companyJoined = companyJoined {
                        switch await repository.company.getJoinedById(id: companyJoined.id) {
                        case let .success(company):
                            await MainActor.run {
                                self.companyJoined = company
                            }
                        case let .failure(error):
                            print(error)
                        }
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
