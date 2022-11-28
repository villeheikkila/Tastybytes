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
            .navigationBarItems(trailing: navigationBarMenu)
            .sheet(item: $viewModel.activeSheet) { sheet in
                NavigationStack {
                    switch sheet {
                    case .editSuggestion:
                        companyEditSuggestionSheet
                    case .editCompany:
                        companyEditDirectlySheet
                    case .editBrand:
                        if let editBrand = viewModel.editBrand {
                            EditBrandSheetView(brand: editBrand, brandOwner: company) {
                                viewModel.refreshData(companyId: company.id)
                            }
                        }
                    case .mergeProduct:
                        if let productToMerge = viewModel.productToMerge {
                            MergeSheetView(productToMerge: productToMerge)
                        }
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

    var navigationBarMenu: some View {
        Menu {
            ShareLink("Share", item: createLinkToScreen(.company(id: company.id)))

            if profileManager.hasPermission(.canEditCompanies) {
                Button(action: {
                    viewModel.setActiveSheet(.editCompany)
                }) {
                    Label("Edit", systemImage: "pencil")
                }
            } else {
                Button(action: {
                    viewModel.setActiveSheet(.editSuggestion)
                }) {
                    Label("Edit Suggestion", systemImage: "pencil")
                }
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
                        Menu {
                            if profileManager.hasPermission(.canDeleteBrands) {
                                Button(action: {
                                    showDeleteBrandConfirmationDialog.toggle()
                                }) {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                            if profileManager.hasPermission(.canEditBrands) {
                                Button(action: {
                                    viewModel.editBrand = brand
                                    viewModel.setActiveSheet(.editBrand)
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
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
                Button("Send") {
                    viewModel.sendCompanyEditSuggestion()
                }
                .disabled(!validateStringLength(str: viewModel.newCompanyNameSuggestion, type: .normal))
            } header: {
                Text("What should the company be called?")
            }
        }
        .navigationTitle("Edit suggestion")
    }

    var companyEditDirectlySheet: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.newCompanyNameSuggestion)
                Button("Edit") {
                    viewModel.editCompany()
                }
                .disabled(!validateStringLength(str: viewModel.newCompanyNameSuggestion, type: .normal))
            } header: {
                Text("Company name")
            }
        }
        .navigationTitle("Edit Company")
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

struct EditBrandSheetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ViewModel()
    @State var name: String
    @State var brandOwner: Company

    let brand: Brand.JoinedSubBrandsProducts
    let onUpdate: () -> Void

    init(brand: Brand.JoinedSubBrandsProducts, brandOwner: Company, onUpdate: @escaping () -> Void) {
        self.brand = brand
        _brandOwner = State(initialValue: brandOwner)
        _name = State(initialValue: brand.name)
        self.onUpdate = onUpdate
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                Button(action: {
                    viewModel.activeSheet = Sheet.brandOwner
                }) {
                    Text(brandOwner.name)
                }
                Button("Edit") {
                    viewModel.editBrand(brand: brand, name: name, brandOwner: brandOwner) {
                        dismiss()
                        onUpdate()
                    }
                }
                .disabled(!validateStringLength(str: name, type: .normal))
            } header: {
                Text("Brand name")
            }
        }
        .navigationTitle("Edit Brand")
        .navigationBarItems(trailing: Button(action: {
            dismiss()
        }) {
            Text("Cancel").bold()
        })
        .sheet(item: $viewModel.activeSheet) { sheet in NavigationStack {
            switch sheet {
            case .brandOwner:
                CompanySheetView(onSelect: { company, _ in
                    brandOwner = company
                    viewModel.activeSheet = nil
                })
            }
        }
        }
    }
}

extension EditBrandSheetView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case brandOwner
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var activeSheet: Sheet?

        func editBrand(brand: Brand.JoinedSubBrandsProducts, name: String, brandOwner: Company, onSuccess: @escaping () -> Void) {
            Task {
                switch await repository.brand.update(updateRequest: Brand.UpdateRequest(id: brand.id, name: name, brandOwnerId: brandOwner.id)) {
                case .success:
                    onSuccess()
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}

extension CompanyScreenView {
    enum Sheet: Identifiable {
        var id: Self { self }
        case editSuggestion
        case editCompany
        case editBrand
        case mergeProduct
    }

    @MainActor class ViewModel: ObservableObject {
        @Published var companyJoined: Company.Joined?
        @Published var companySummary: Company.Summary?
        @Published var activeSheet: Sheet?
        @Published var newCompanyNameSuggestion = ""
        @Published var productToMerge: Product.JoinedCategory?
        @Published var productToDelete: Product.JoinedCategory?
        @Published var editBrand: Brand.JoinedSubBrandsProducts?

        func setActiveSheet(_ sheet: Sheet) {
            activeSheet = sheet
        }

        func sendCompanyEditSuggestion() {
        }

        func editCompany() {
            if let companyJoined = companyJoined {
                Task {
                    switch await repository.company.update(updateRequest: Company.UpdateRequest(id: companyJoined.id, name: newCompanyNameSuggestion)) {
                    case let .success(updatedCompany):
                        await MainActor.run {
                            self.companyJoined = updatedCompany
                            self.activeSheet = nil
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }

        func refreshData(companyId: Int) {
            Task {
                switch await repository.company.getJoinedById(id: companyId) {
                case let .success(company):
                    await MainActor.run {
                        self.companyJoined = company
                        self.newCompanyNameSuggestion = company.name
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
