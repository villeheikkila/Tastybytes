import SwiftUI

enum SearchScope: String, CaseIterable {
    case products
    case companies
    case users
}

struct SearchScreenView: View {
    @ObservedObject var viewModel: SearchScreenViewModel

    var body: some View {
        List {
            switch viewModel.searchScope {
            case .products:
                productResults
                if viewModel.isSearched {
                    Section {
                        NavigationLink("Add new", value: Route.addProduct)
                            .fontWeight(.medium)
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
        .searchable(text: $viewModel.searchTerm)
        .searchScopes($viewModel.searchScope) {
            Text("Products").tag(SearchScope.products)
            Text("Companies").tag(SearchScope.companies)
            Text("Users").tag(SearchScope.users)
        }
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
            BarcodeScannerSheetView(onComplete: {
                barcode in viewModel.searchProductsByBardcode(barcode)
            })
            .presentationDetents([.medium])
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
            NavigationLink(value: product) {
                ProductListItemView(product: product)
            }
        }
    }
}

class SearchScreenViewModel: ObservableObject {
    @Published var searchTerm: String = ""
    @Published var products = [ProductJoined]()
    @Published var profiles = [Profile]()
    @Published var companies = [Company]()
    @Published var showBarcodeScanner = false
    @Published var isSearched = false
    @Published var searchScope: SearchScope = .products

    func resetSearch() {
        profiles = []
        products = []
        companies = []
    }

    func searchProducts() {
        Task {
            switch await repository.product.search(searchTerm: searchTerm) {
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
                print(searchResults)
                await MainActor.run {
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
