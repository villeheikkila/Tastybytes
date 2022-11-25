import CachedAsyncImage
import SwiftUI

struct CompanyScreenView: View {
    let company: Company
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var routeManager: RouteManager
    @StateObject private var viewModel = ViewModel()
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var showDeleteBrandConfirmationDialog = false

    var body: some View {
        List {
            VStack(alignment: .leading) {
                companyHeader
                if let companySummary = viewModel.companySummary {
                    SummaryView(companySummary: companySummary)
                }
            }
            .listRowBackground(Color.clear)
            .navigationTitle(company.name)
            .contextMenu {
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
            .sheet(item: $viewModel.activeSheet) { sheet in
                switch sheet {
                case .editSuggestion:
                    companyEditSuggestionSheet
                case .mergeProduct:
                    mergeProductSheet
                }
            }

            if let companyJoined = viewModel.companyJoined {
                ForEach(companyJoined.brands, id: \.id) { brand in
                    Section {
                        ForEach(brand.subBrands, id: \.id) {
                            subBrand in
                            ForEach(subBrand.products, id: \.id) {
                                product in
                                NavigationLink(value: Product.Joined(company: company, product: product, subBrand: subBrand, brand: brand)) {
                                    HStack {
                                        Text(joinOptionalStrings([brand.name, subBrand.name, product.name]))
                                            .lineLimit(nil)
                                        Spacer()
                                    }.contextMenu {
                                        if profileManager.hasPermission(.canMergeProducts) {
                                            Button(action: {
                                                viewModel.productToMerge = product
                                                viewModel.setActiveSheet(.mergeProduct)
                                            }) {
                                                Text("Merge product to...")
                                            }
                                        }
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

    var companyEditSuggestionSheet: some View {
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

    var mergeProductSheet: some View {
        NavigationStack {
            List {
                if let productSearchResults = viewModel.productSearchResults {
                    ForEach(productSearchResults, id: \.self) { product in
                        Button(action: {
                            viewModel.mergeToProduct = product
                            viewModel.isPresentingProductMergeConfirmation.toggle()
                        }) {
                            ProductListItemView(product: product)
                        }.buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Merge to...")
            .confirmationDialog("Are you sure?",
                                isPresented: $viewModel.isPresentingProductMergeConfirmation) {
              Button("Merge. This can't be undone.", role: .destructive) {
                  viewModel.mergeProducts()
              }
            } message: {
                if let productToMerge = viewModel.productToMerge, let mergeToProduct = viewModel.mergeToProduct {
                    Text("Merge \(productToMerge.name) to \(mergeToProduct.getDisplayName(.fullName))")
                }
            }
        }
        .searchable(text: $viewModel.productSearchTerm)
        .onSubmit(of: .search, {
            viewModel.searchProducts()
        })
    }

    var companyHeader: some View {
        HStack(spacing: 10) {
            if let logoUrl = company.getLogoUrl() {
                CachedAsyncImage(url: logoUrl, urlCache: .imageCache) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 52, height: 52)
                } placeholder: {
                    Image(systemName: "photo")
                }
            }
            Spacer()
        }
    }
}

extension CompanyScreenView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case editSuggestion
        case mergeProduct
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var companyJoined: Company.Joined?
        @Published var companySummary: Company.Summary?
        @Published var activeSheet: Sheet?

        @Published var newCompanyNameSuggestion = ""

        @Published var productToMerge: Product.JoinedCategory?
        @Published var mergeToProduct: Product.Joined?
        @Published var isPresentingProductMergeConfirmation = false
        @Published var productSearchTerm = ""
        @Published var productSearchResults: [Product.Joined] = []

        func setActiveSheet(_ sheet: Sheet) {
            activeSheet = sheet
        }

        func sendCompanyEditSuggestion() {
        }
        
        func mergeProducts() {
            if let productToMerge = productToMerge, let mergeToProduct = mergeToProduct {
                Task {
                    switch await repository.product.mergeProducts(productId: productToMerge.id, toProductId: mergeToProduct.id) {
                    case .success():
                        print("success")
                        self.productToMerge = nil
                        self.mergeToProduct = nil
                        self.activeSheet = nil
                    case let .failure(error):
                        print(error)
                    }
                }
            }
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
                    print(error)
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

        func searchProducts() {
            Task {
                switch await repository.product.search(searchTerm: productSearchTerm, categoryName: nil) {
                case let .success(searchResults):
                    await MainActor.run {
                        if let productToMergeId = productToMerge?.id {
                            self.productSearchResults = searchResults.filter { $0.id != productToMergeId }
                        }
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func deleteBrand(_ brand: Brand.JoinedSubBrandsProducts) {
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
