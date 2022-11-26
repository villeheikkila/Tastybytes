import CachedAsyncImage
import SwiftUI

struct CompanyScreenView: View {
    let company: Company
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var routeManager: RouteManager
    @StateObject private var viewModel = ViewModel()
    @State private var showDeleteCompanyConfirmationDialog = false
    @State private var showDeleteBrandConfirmationDialog = false
    @State private var showDeleteProductConfirmationDialog = false

    var body: some View {
        List {
            Section {
                companyHeader
                if let companySummary = viewModel.companySummary, companySummary.averageRating != nil {
                    SummaryView(companySummary: companySummary)
                }
            }
            .navigationTitle(company.name)
            .navigationBarItems(trailing:
                Menu {
                    ShareLink("Share", item: createLinkToScreen(.company(id: company.id)))
                    Button(action: {
                        viewModel.setActiveSheet(.editSuggestion)
                    }) {
                        Label("Edit Suggestion", systemImage: "pencil")
                    }
                
                    Divider()
                
                    if profileManager.hasPermission(.canDeleteCompanies) {
                        Button(action: {
                            showDeleteCompanyConfirmationDialog.toggle()
                        }) {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                })
            .sheet(item: $viewModel.activeSheet) { sheet in
                switch sheet {
                case .editSuggestion:
                    companyEditSuggestionSheet
                case .mergeProduct:
                    if let productToMerge = viewModel.productToMerge {
                        MergeSheetView(productToMerge: productToMerge)
                    }
                }
            }

            productList
        }
        .confirmationDialog("Delete Company Confirmation",
                            isPresented: $showDeleteCompanyConfirmationDialog
        ) {
            Button("Delete Company", role: .destructive, action: {
                viewModel.deleteCompany(company, onDelete: {
                    routeManager.gotoHomePage()
                })
            })
        }
        .confirmationDialog("Delete Product Confirmation",
                            isPresented: $showDeleteProductConfirmationDialog
        ) {
            Button("Delete Product \(viewModel.productToDelete?.name ?? ""). This can't be undone.", role: .destructive, action: {
                viewModel.deleteProduct()
            })
        }
        .task {
            viewModel.refreshData(companyId: company.id)
        }
    }

    @ViewBuilder
    var productList: some View {
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
                                }
                                .contextMenu {
                                    if profileManager.hasPermission(.canMergeProducts) {
                                        Button(action: {
                                            viewModel.productToMerge = product
                                            viewModel.setActiveSheet(.mergeProduct)
                                        }) {
                                            Text("Merge product to...")
                                        }
                                    }

                                    if profileManager.hasPermission(.canDeleteProducts) {
                                        Button(action: {
                                            showDeleteProductConfirmationDialog.toggle()
                                            viewModel.productToDelete = product
                                        }) {
                                            Label("Delete", systemImage: "trash.fill")
                                                .foregroundColor(.red)
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
                .confirmationDialog("Delete Brand Confirmation",
                                    isPresented: $showDeleteBrandConfirmationDialog
                ) {
                    Button("Delete Brand", role: .destructive, action: { viewModel.deleteBrand(brand) })
                }
            }
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
        @Published var productToDelete: Product.JoinedCategory?

        func setActiveSheet(_ sheet: Sheet) {
            activeSheet = sheet
        }

        func sendCompanyEditSuggestion() {
        }

        func refreshData(companyId: Int) {
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

        func deleteProduct() {
            if let productToDelete = productToDelete, let companyJoined = companyJoined {
                Task {
                    switch await repository.product.delete(id: productToDelete.id) {
                    case .success():
                        refreshData(companyId: companyJoined.id)
                        self.productToDelete = nil
                    case let .failure(error):
                        print(error)
                    }
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
                            refreshData(companyId: company.id)
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
