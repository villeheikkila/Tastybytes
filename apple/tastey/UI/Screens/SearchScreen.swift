import SwiftUI

enum SearchScope: String, CaseIterable {
    case products
    case companies
    case users
}

struct SearchScreenView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        NavigationView {
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
            .navigationTitle("Search")
            .onSubmit(of: .search, viewModel.search)
            .listStyle(InsetGroupedListStyle())
        }
    }

    var profileResults: some View {
        ForEach(viewModel.profiles, id: \.self) { profile in
            NavigationLink(value: profile) {
                HStack(alignment: .center) {
                    AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
                    VStack {
                        HStack {
                            Text(profile.getPreferedName())
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

extension SearchScreenView {
    class ViewModel: ObservableObject {
        @Published var searchTerm: String = ""
        @Published var products = [Product]()
        @Published var profiles = [Profile]()
        @Published var companies = [Company]()

        @Published var isSearched = false
        @Published var searchScope: SearchScope = .products
        
        func resetSearch() {
            DispatchQueue.main.async {
                self.profiles = []
                self.products = []
                self.companies = []
            }
        }

        func searchProducts() {
            Task {
                let searchResults = try await repository.product.search(searchTerm: searchTerm)
                DispatchQueue.main.async {
                    self.products = searchResults
                    self.isSearched = true
                }
            }
        }

        func searchProfiles() {
            let currentUserId = repository.auth.getCurrentUserId()
            Task {
                let searchResults = try await repository.profile.search(searchTerm: searchTerm, currentUserId: currentUserId)
                DispatchQueue.main.async {
                    self.profiles = searchResults
                }
            }
        }

        func searchCompanies() {
            Task {
                let searchResults = try await repository.company.search(searchTerm: searchTerm)
                DispatchQueue.main.async {
                    self.companies = searchResults
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
}
