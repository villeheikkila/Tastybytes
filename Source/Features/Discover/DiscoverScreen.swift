import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct DiscoverScreen: View {
    private let logger = Logger(category: "SearchListView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    // Search Query
    @State private var searchScope: SearchScope = .products
    @State private var searchTerm = ""
    @State private var searchKey: SearchKey?
    @State private var productFilter: Product.Filter?
    // Search Result
    @State private var searchResultKey: SearchKey?
    @State private var products = [Product.Joined]()
    @State private var profiles = [Profile.Saved]()
    @State private var companies = [Company.Saved]()
    @State private var locations = [Location.Saved]()
    // Search State
    @State private var error: Error?
    // Barcode
    @State private var barcode: Barcode?

    private var currentScopeIsEmpty: Bool {
        switch searchScope {
        case .companies:
            companies.isEmpty
        case .locations:
            locations.isEmpty
        case .products:
            products.isEmpty
        case .users:
            profiles.isEmpty
        }
    }

    private var isLoading: Bool {
        searchKey != searchResultKey
    }

    private var showContentUnavailableView: Bool {
        searchResultKey != nil && !isLoading && currentScopeIsEmpty
    }

    private var showAddProductViewRow: Bool {
        searchScope == .products && searchResultKey != nil && searchKey == searchResultKey && !showContentUnavailableView && profileEnvironmentModel
            .hasPermission(.canCreateProducts)
    }

    var body: some View {
        List {
            switch searchScope {
            case .products:
                DiscoverProductResults(
                    products: products,
                    barcode: $barcode,
                    showContentUnavailableView: showContentUnavailableView,
                    searchKey: searchKey,
                    searchResultKey: searchResultKey
                )
            case .companies:
                DiscoverCompanyResults(companies: companies)
            case .users:
                DiscoverProfileResults(profiles: profiles)
            case .locations:
                DiscoverLocationResults(locations: locations)
            }
        }
        .listStyle(.plain)
        .overlay {
            if let error, currentScopeIsEmpty {
                ScreenContentUnavailableView(errors: [error], description: nil) {
                    await loadData(searchKey: searchKey, productFilter: productFilter)
                }
            }
        }
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: searchScope.prompt)
        .searchScopes($searchScope, activation: .onSearchPresentation) {
            ForEach(SearchScope.allCases) { scope in
                Text(scope.label).tag(scope)
            }
        }
        .disableAutocorrection(true)
        .safeAreaInset(edge: .bottom, content: {
            if showAddProductViewRow {
                Form {
                    DiscoverProductAddNew(barcode: $barcode)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollContentBackground(.hidden)
                .background(.thinMaterial)
                .frame(height: 90)
                .clipShape(.rect(cornerRadius: 8))
                .padding()
            }
        })
        .safeAreaInset(edge: .top) {
            if searchScope == .products, barcode != nil, !showContentUnavailableView {
                DiscoverProductAssignBarcode(isEmpty: products.isEmpty, barcode: $barcode)
            } else if searchScope == .products, let productFilter {
                ProductFilterOverlayView(filters: productFilter, onReset: { self.productFilter = nil })
            }
        }
        .onSubmit(of: .search) {
            if searchTerm.isEmpty {
                searchKey = nil
            } else {
                searchKey = .text(searchTerm: searchTerm, searchScope: searchScope)
            }
        }
        .navigationTitle("discover.title")
        .toolbar {
            toolbarContent
        }
        .overlay {
            if showContentUnavailableView {
                contentUnavailableView
            }
        }
        .task(id: searchKey, milliseconds: 200) { [searchKey] in
            await loadData(searchKey: searchKey, productFilter: productFilter)
        }
        .onChange(of: searchScope) {
            searchKey = .text(searchTerm: searchTerm, searchScope: searchScope)
            barcode = nil
            searchResultKey = nil
        }
        .onChange(of: productFilter) {
            searchKey = .text(searchTerm: searchTerm, searchScope: searchScope)
        }
        .onChange(of: searchTerm) { _, searchTerm in
            if searchTerm.isEmpty {
                searchKey = nil
            } else {
                searchKey = .text(searchTerm: searchTerm, searchScope: searchScope)
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if searchScope == .products {
            ToolbarItemGroup(placement: .topBarLeading) {
                RouterLink(
                    "discover.filter.show",
                    systemImage: "line.3.horizontal.decrease.circle",
                    open: .sheet(.productFilter(
                        initialFilter: productFilter,
                        sections: [.category, .checkIns],
                        onApply: { filter in
                            productFilter = filter
                        }
                    ))
                ).labelStyle(.iconOnly)
            }

            if profileEnvironmentModel.hasPermission(.canAddBarcodes) {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    RouterLink(
                        "discover.barcode.scan",
                        systemImage: "barcode.viewfinder",
                        open: .sheet(.barcodeScanner(onComplete: { barcode in
                            self.barcode = barcode
                            searchKey = .barcode(barcode)
                        }))
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var contentUnavailableView: some View {
        switch searchResultKey {
        case .barcode:
            ContentUnavailableView {
                Label("discover.barcode.notFound.title", systemImage: "bubbles.and.sparkles")
            } actions: {
                createProductButton
            }
        case let .text(searchTerm, searchScope):
            switch searchScope {
            case .companies:
                ContentUnavailableView {
                    Label("discover.companies.notFound.title \"\(searchTerm)\"", systemImage: "storefront")
                } description: {
                    Text("discover.companies.notFound.description")
                }
            case .locations:
                ContentUnavailableView {
                    Label("discover.locations.notFound.title \"\(searchTerm)\"", systemImage: "location.magnifyingglass")
                } description: {
                    Text("discover.locations.notFound.description")
                }
            case .products:
                ContentUnavailableView {
                    Label("discover.procucts.notFound.title \"\(searchTerm)\"", systemImage: "bubbles.and.sparkles")
                } description: {
                    Text("discover.products.notFound.description")
                } actions: {
                    createProductButton
                }
            case .users:
                ContentUnavailableView {
                    Label(
                        "discover.users.notFound.title \"\(searchTerm)\"",
                        systemImage: "person.crop.circle.badge.questionmark"
                    )
                } description: {
                    Text("discover.users.notFound.description")
                }
            }
        case nil:
            EmptyView()
        }
    }

    private func loadData(searchKey: SearchKey?, productFilter: Product.Filter?) async {
        guard let searchKey else {
            logger.info("Empty search key. Reset.")
            withAnimation {
                profiles = []
                products = []
                companies = []
                locations = []
                searchResultKey = nil
            }
            return
        }
        if searchKey == searchResultKey {
            logger.info("Already showing search results for id: \(searchKey.id). Skip.")
            return
        }
        logger.info("Staring search for id: '\(searchKey.id)'")
        switch searchKey {
        case let .barcode(barcode):
            do {
                let searchResults = try await repository.product.search(barcode: barcode)
                withAnimation {
                    products = searchResults
                    searchResultKey = searchKey
                    error = nil
                }
                if searchResults.count == 1, let result = searchResults.first {
                    router.open(.screen(.productFromBarcode(result.id, barcode)))
                }
            } catch {
                guard !error.isCancelled else { return }
                self.error = error
                logger.error("Searching products with barcode failed. Error: \(error) (\(#file):\(#line))")
            }
        case let .text(searchTerm, searchScope):
            if searchTerm.count < 2 { return }
            switch searchScope {
            case .products:
                do {
                    let searchResults = try await repository.product.search(searchTerm: searchTerm, filter: productFilter)
                    withAnimation {
                        products = searchResults
                        searchResultKey = searchKey
                        error = nil
                    }
                    logger.info("Search completed for id: '\(searchKey.id)'")
                } catch {
                    if error.isCancelled {
                        logger.info("Search cancelled for id: '\(searchKey.id)'")
                        return
                    }
                    self.error = error
                    logger.error("Searching products failed. Error: \(error) (\(#file):\(#line))")
                }
            case .companies:
                do {
                    let searchResults = try await repository.company.search(filterCompanies: [], searchTerm: searchTerm)
                    withAnimation {
                        companies = searchResults
                        searchResultKey = searchKey
                        error = nil
                    }
                    logger.info("Search completed for id: '\(searchKey.id)'")
                } catch {
                    guard !error.isCancelled else { return }
                    self.error = error
                    logger.error("Searching companies failed. Error: \(error) (\(#file):\(#line))")
                }
            case .users:
                do {
                    let searchResults = try await repository.profile.search(searchTerm: searchTerm, currentUserId: nil)
                    withAnimation {
                        profiles = searchResults
                        searchResultKey = searchKey
                        error = nil
                    }
                    logger.info("Search completed for id: '\(searchKey.id)'")
                } catch {
                    guard !error.isCancelled else { return }
                    self.error = error
                    logger.error("Searching profiles failed. Error: \(error) (\(#file):\(#line))")
                }
            case .locations:
                do {
                    let searchResults = try await repository.location.search(searchTerm: searchTerm)
                    withAnimation {
                        locations = searchResults
                        searchResultKey = searchKey
                        error = nil
                    }
                    logger.info("Search completed for id: '\(searchKey.id)'")
                } catch {
                    guard !error.isCancelled else { return }
                    self.error = error
                    logger.error("Searching locations failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        }
    }

    @ViewBuilder private var createProductButton: some View {
        Button("checkIn.action.createNew") {
            router.open(.sheet(.product(.new(barcode: barcode, onCreate: { product in
                router.open(.screen(.product(product.id)))
            }))))
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
    }
}
