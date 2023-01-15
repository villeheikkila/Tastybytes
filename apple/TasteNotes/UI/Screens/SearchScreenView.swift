import SwiftUI

struct SearchScreenView: View {
    @ObservedObject var viewModel: SearchScreenViewModel
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var profileManager: ProfileManager
    @State private var showAddBarcodeConfirmation = false

    var body: some View {
        List {
            switch viewModel.searchScope {
            case .products:
                productResults
                if viewModel.isSearched {
                    if viewModel.barcode != nil {
                        Section {
                            Text("\(viewModel.products.isEmpty ? "No results were found" : "If none of the results match"), you can assign the barcode to a product by searching again with the name or by creating a new product.")
                            Button(action: {
                                viewModel.resetBarcode()
                            }) {
                                Text("Dismiss barcode")
                            }
                        }
                    }
                    Section {
                        NavigationLink("Add new", value: Route.addProduct(viewModel.barcode))
                            .fontWeight(.medium)
                            .disabled(!profileManager.hasPermission(.canCreateProducts))
                    } header: {
                        Text("Didn't find a product you were looking for?")
                    }
                    .textCase(nil)
                }
            case .companies:
                companyResults
            case .users:
                profileResults
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onChange(of: viewModel.searchScope, perform: { _ in
            viewModel.search()
        })
        .onChange(of: viewModel.searchTerm, perform: {
            term in
            if term.isEmpty {
                viewModel.resetSearch()
            }
        })
        .onSubmit(of: .search, viewModel.search)
        .sheet(isPresented: $viewModel.showBarcodeScanner) {
            NavigationStack {
                BarcodeScannerSheetView(onComplete: {
                    barcode in viewModel.searchProductsByBardcode(barcode)
                })
                .presentationDetents([.medium])
            }
        }
    }

    var profileResults: some View {
        ForEach(viewModel.profiles, id: \.self) { profile in
            NavigationLink(value: profile) {
                HStack(alignment: .center) {
                    AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
                    VStack {
                        HStack {
                            Text(profile.preferredName)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    var companyResults: some View {
        ForEach(viewModel.companies, id: \.self) { company in
            NavigationLink(value: company) {
                Text(company.name)
            }
        }
    }

    var productResults: some View {
        ForEach(viewModel.products, id: \.self) { product in
            if viewModel.barcode == nil || product.barcodes.contains(where: { $0.isBarcode(viewModel.barcode) }) {
                NavigationLink(value: product) {
                    ProductListItemView(product: product)
                }
            } else {
                Button(action: {
                    showAddBarcodeConfirmation.toggle()
                }) {
                    ProductListItemView(product: product)
                }.buttonStyle(.plain)
                    .confirmationDialog("Are you sure you want to add the barcode to product \(product.id)",
                                        isPresented: $showAddBarcodeConfirmation
                    ) {
                        Button("Add barcode", action: {
                            viewModel.addBarcodeToProduct(product, onComplete: {
                                toastManager.toggle(.success("Barcode added!"))
                            })
                        })
                    }
            }
        }
    }
}

class SearchScreenViewModel: ObservableObject {
    @Published var searchTerm: String = "" {
        didSet {
            if let firstPartOfSearchString = searchTerm.lowercased().split(separator: " ", maxSplits: 1).map(String.init).first {
                if let category = Category.Name(rawValue: firstPartOfSearchString) {
                    tokens = [category]
                    searchTerm = ""
                }
            }
        }
    }

    @Published var products = [Product.Joined]()
    @Published var profiles = [Profile]()
    @Published var companies = [Company]()
    @Published var showBarcodeScanner = false
    @Published var isSearched = false
    @Published var searchScope: SearchScope = .products
    @Published var barcode: Barcode? = nil
    @Published var tokens: [Category.Name] = []

    func resetSearch() {
        profiles = []
        products = []
        companies = []
    }

    func resetBarcode() {
        DispatchQueue.main.async {
            self.barcode = nil
        }
    }

    func addBarcodeToProduct(_ product: Product.Joined, onComplete: @escaping () -> Void) {
        if let barcode = barcode {
            Task {
                switch await repository.product.addBarcodeToProduct(product: product, barcode: barcode) {
                case .success:
                    await MainActor.run {
                        self.barcode = nil
                        onComplete()
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func searchProducts() {
        Task {
            switch await repository.product.search(searchTerm: searchTerm, categoryName: tokens.first) {
            case let .success(searchResults):
                await MainActor.run {
                    self.products = searchResults
                    self.isSearched = true
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    func searchProfiles() {
        let currentUserId = repository.auth.getCurrentUserId()
        Task {
            switch await repository.profile.search(searchTerm: searchTerm, currentUserId: currentUserId) {
            case let .success(searchResults):
                await MainActor.run {
                    self.profiles = searchResults
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    func searchProductsByBardcode(_ barcode: Barcode) {
        Task {
            switch await repository.product.search(barcode: barcode) {
            case let .success(searchResults):
                await MainActor.run {
                    self.barcode = barcode
                    self.products = searchResults
                    self.isSearched = true
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    func searchCompanies() {
        Task {
            switch await repository.company.search(searchTerm: searchTerm) {
            case let .success(searchResults):
                await MainActor.run {
                    self.companies = searchResults
                }

            case let .failure(error):
                print(error)
            }
        }
    }

    func search() {
        switch searchScope {
        case .products:
            searchProducts()
        case .companies:
            searchCompanies()
        case .users:
            searchProfiles()
        }
    }
}

enum SearchScope: String, CaseIterable {
    case products
    case companies
    case users
}
