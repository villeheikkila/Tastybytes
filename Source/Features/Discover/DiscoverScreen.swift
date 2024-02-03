import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct DiscoverScreen: View {
    private let logger = Logger(category: "SearchListView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var sheet: Sheet?
    // Scroll Position
    @Binding var scrollToTop: Int
    // Search Query
    @State private var searchScope: SearchScope = .products
    @State private var searchTerm = ""
    @State private var searchKey: SearchKey?
    @State private var productFilter: Product.Filter?
    // Search Result
    @State private var searchResultKey: SearchKey?
    @State private var scrollProxy: ScrollViewProxy?
    @State private var products = [Product.Joined]()
    @State private var profiles = [Profile]()
    @State private var companies = [Company]()
    @State private var locations = [Location]()
    // Search State
    @State private var alertError: AlertError?
    // Barcode
    @State private var barcode: Barcode?

    var currentScopeIsEmpty: Bool {
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
        .sheets(item: $sheet)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: searchScope.prompt)
        .searchScopes($searchScope, activation: .onSearchPresentation) {
            ForEach(SearchScope.allCases) { scope in
                Text(scope.label).tag(scope)
            }
        }
        .disableAutocorrection(true)
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
            contentUnavailableView.opacity(showContentUnavailableView ? 1 : 0)
        }
        .overlay {
            if searchScope == .products, let productFilter {
                ProductFilterOverlayView(filters: productFilter, onReset: { self.productFilter = nil })
            }
        }
        .alertError($alertError)
        .task(id: searchKey, milliseconds: 200) { @MainActor [searchKey] in
            await loadData(searchKey: searchKey)
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
        .onChange(of: scrollToTop) {
            withAnimation {
                switch searchScope {
                case .products:
                    if let id = products.first?.id {
                        scrollProxy?.scrollTo(id, anchor: .top)
                    }
                case .companies:
                    if let id = companies.first?.id {
                        scrollProxy?.scrollTo(id, anchor: .top)
                    }
                case .users:
                    if let id = profiles.first?.id {
                        scrollProxy?.scrollTo(id, anchor: .top)
                    }
                case .locations:
                    if let id = locations.first?.id {
                        scrollProxy?.scrollTo(id, anchor: .top)
                    }
                }
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if searchScope == .products {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(
                    "discover.filter.show",
                    systemImage: "line.3.horizontal.decrease.circle",
                    action: { sheet = .productFilter(
                        initialFilter: productFilter,
                        sections: [.category, .checkIns],
                        onApply: { filter in
                            productFilter = filter
                        }
                    ) }
                ).labelStyle(.iconOnly)
            }

            if profileEnvironmentModel.hasPermission(.canAddBarcodes) {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(
                        "discover.barcode.scan",
                        systemImage: "barcode.viewfinder",
                        action: { sheet = .barcodeScanner(onComplete: { barcode in
                            self.barcode = barcode
                            searchKey = .barcode(barcode)
                        }) }
                    )
                }
            }
        }
    }

    @ViewBuilder
    var contentUnavailableView: some View {
        switch searchResultKey {
        case let .barcode(barcode):
            ContentUnavailableView {
                Label("discover.barcode.notFound.title", systemImage: "bubbles.and.sparkles")
            } actions: {
                Button("checkIn.action.createNew") {
                    router.navigate(screen: .addProduct(barcode))
                }
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
                    Button("checkIn.action.createNew") {
                        let barcodeCopy = barcode
                        barcode = nil
                        router.navigate(screen: .addProduct(barcodeCopy))
                    }
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

    func loadData(searchKey: SearchKey?) async {
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
            switch await repository.product.search(barcode: barcode) {
            case let .success(searchResults):
                withAnimation {
                    products = searchResults
                    searchResultKey = searchKey
                }
                if searchResults.count == 1, let result = searchResults.first {
                    router.fetchAndNavigateTo(repository, .productWithBarcode(id: result.id, barcode: barcode))
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                alertError = .init()
                logger.error("Searching products with barcode failed. Error: \(error) (\(#file):\(#line))")
            }
        case let .text(searchTerm, searchScope):
            if searchTerm.count < 2 { return }
            switch searchScope {
            case .products:
                switch await repository.product.search(searchTerm: searchTerm, filter: productFilter) {
                case let .success(searchResults):
                    withAnimation {
                        products = searchResults
                        searchResultKey = searchKey
                    }
                    logger.info("Search completed for id: '\(searchKey.id)'")
                case let .failure(error):
                    if error.isCancelled {
                        logger.info("Search cancelled for id: '\(searchKey.id)'")
                        return
                    }
                    alertError = .init()
                    logger.error("Searching products failed. Error: \(error) (\(#file):\(#line))")
                }
            case .companies:
                switch await repository.company.search(searchTerm: searchTerm) {
                case let .success(searchResults):
                    withAnimation {
                        companies = searchResults
                        searchResultKey = searchKey
                    }
                    logger.info("Search completed for id: '\(searchKey.id)'")
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Searching companies failed. Error: \(error) (\(#file):\(#line))")
                }
            case .users:
                switch await repository.profile.search(searchTerm: searchTerm, currentUserId: nil) {
                case let .success(searchResults):
                    withAnimation {
                        profiles = searchResults
                        searchResultKey = searchKey
                    }
                    logger.info("Search completed for id: '\(searchKey.id)'")
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Searching profiles failed. Error: \(error) (\(#file):\(#line))")
                }
            case .locations:
                switch await repository.location.search(searchTerm: searchTerm) {
                case let .success(searchResults):
                    withAnimation {
                        locations = searchResults
                        searchResultKey = searchKey
                    }
                    logger.info("Search completed for id: '\(searchKey.id)'")
                case let .failure(error):
                    guard !error.isCancelled else { return }
                    alertError = .init()
                    logger.error("Searching locations failed. Error: \(error) (\(#file):\(#line))")
                }
            }
        }
    }
}
