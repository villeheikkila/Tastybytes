import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct DiscoverScreen: View {
    private let logger = Logger(category: "SearchListView")
    @Environment(\.repository) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
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
    @State private var showAddBarcodeConfirmation = false
    @State private var addBarcodeTo: Product.Joined? {
        didSet {
            showAddBarcodeConfirmation = true
        }
    }

    private var isLoading: Bool {
        searchKey != searchResultKey
    }

    private var showContentUnavailableView: Bool {
        searchResultKey != nil && !isLoading && currentScopeIsEmpty
    }

    private var showAddProductViewRow: Bool {
        searchResultKey != nil && searchKey == searchResultKey && !showContentUnavailableView && profileEnvironmentModel
            .hasPermission(.canCreateProducts)
    }

    var body: some View {
        List {
            switch searchScope {
            case .products:
                productResults
            case .companies:
                companyResults
            case .users:
                profileResults
            case .locations:
                locationResults
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: searchScope.prompt)
        .searchScopes($searchScope, activation: .onSearchPresentation) {
            ForEach(SearchScope.allCases) { scope in
                Text(scope.label).tag(scope)
            }
        }
        .overlay {
            contentUnavailableView.opacity(showContentUnavailableView ? 1 : 0)
        }
        .disableAutocorrection(true)
        .onSubmit(of: .search) {
            if searchTerm.isEmpty {
                searchKey = nil
            } else {
                searchKey = .text(searchTerm: searchTerm, searchScope: searchScope)
            }
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
        .navigationTitle("Discover")
        .dismissSplashScreen()
        .task(id: searchKey, milliseconds: 200) { [searchKey] in
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
                    logger.error("searching products with barcode failed. Error: \(error) (\(#file):\(#line))")
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
                        logger.error("searching products failed. Error: \(error) (\(#file):\(#line))")
                    }
                case .companies:
                    switch await repository.company.search(searchTerm: searchTerm) {
                    case let .success(searchResults):
                        await MainActor.run {
                            withAnimation {
                                companies = searchResults
                                searchResultKey = searchKey
                            }
                        }
                        logger.info("Search completed for id: '\(searchKey.id)'")
                    case let .failure(error):
                        guard !error.isCancelled else { return }
                        alertError = .init()
                        logger.error("searching companies failed. Error: \(error) (\(#file):\(#line))")
                    }
                case .users:
                    switch await repository.profile.search(searchTerm: searchTerm, currentUserId: nil) {
                    case let .success(searchResults):
                        await MainActor.run {
                            withAnimation {
                                profiles = searchResults
                                searchResultKey = searchKey
                            }
                        }
                        logger.info("Search completed for id: '\(searchKey.id)'")
                    case let .failure(error):
                        guard !error.isCancelled else { return }
                        alertError = .init()
                        logger.error("searching profiles failed. Error: \(error) (\(#file):\(#line))")
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
                        logger.error("searching locations failed. Error: \(error) (\(#file):\(#line))")
                    }
                }
            }
        }
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        .confirmationDialog(
            "Add barcode confirmation",
            isPresented: $showAddBarcodeConfirmation,
            presenting: addBarcodeTo
        ) { presenting in
            ProgressButton(
                "Add barcode to \(presenting.getDisplayName(.fullName))",
                action: {
                    await addBarcodeToProduct(presenting)
                }
            )
        }
        .overlay {
            if searchScope == .products, let productFilter {
                ProductFilterOverlayView(filters: productFilter, onReset: { self.productFilter = nil })
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

    private var profileResults: some View {
        ForEach(profiles) { profile in
            RouterLink(screen: .profile(profile)) {
                HStack(alignment: .center) {
                    AvatarView(avatarUrl: profile.avatarUrl, size: 42, id: profile.id)
                    VStack {
                        HStack {
                            Text(profile.preferredName)
                                .padding(.leading, 8)
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .id(profile.id)
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                0
            }
        }
    }

    private var companyResults: some View {
        ForEach(companies) { company in
            RouterLink(company.name, screen: .company(company))
                .id(company.id)
        }
    }

    private var locationResults: some View {
        ForEach(locations) { location in
            RouterLink(location.name, screen: .location(location))
                .id(location.id)
        }
    }

    @ViewBuilder private var productResults: some View {
        if barcode != nil && !showContentUnavailableView {
            Section {
                Text(
                    """
                    \(products.isEmpty ? "No results were found" : "If none of the results match"),\
                    you can assign the barcode to a product by searching again \
                    with the name or by creating a new product.
                    """
                )
                Button("Dismiss barcode", action: resetBarcode)
            }
        }

        if currentScopeIsEmpty && addBarcodeTo == nil && searchKey == nil {
            Section("Feeds") {
                Group {
                    RouterLink(
                        Product.FeedType.trending.label,
                        systemImage: "chart.line.uptrend.xyaxis",
                        screen: .productFeed(.trending)
                    )
                    RouterLink(
                        Product.FeedType.topRated.label,
                        systemImage: "line.horizontal.star.fill.line.horizontal",
                        screen: .productFeed(.topRated)
                    )
                    RouterLink(
                        Product.FeedType.latest.label,
                        systemImage: "bolt.horizontal.circle",
                        screen: .productFeed(.latest)
                    )
                }
                .bold()
            }.headerProminence(.increased)
        } else {
            ForEach(products) { product in
                ProductItemView(product: product, extras: [.checkInCheck, .rating])
                    .swipeActions {
                        RouterLink("Check-in", systemImage: "plus", sheet: .newCheckIn(product, onCreation: { checkIn in
                            router.navigate(screen: .checkIn(checkIn))
                        })).tint(.green)
                    }
                    .contentShape(Rectangle())
                    .accessibilityAddTraits(.isLink)
                    .onTapGesture {
                        if barcode == nil || product.barcodes.contains(where: { $0.isBarcode(barcode) }) {
                            router.navigate(screen: .product(product))
                        } else {
                            addBarcodeTo = product
                        }
                    }
                    .id(product.id)
            }
        }
        if showAddProductViewRow {
            Section("Didn't find a product you were looking for?") {
                HStack {
                    Text("Add new")
                        .fontWeight(.medium)
                    Spacer()
                }
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isLink)
                .onTapGesture {
                    let barcodeCopy = barcode
                    barcode = nil
                    router.navigate(screen: .addProduct(barcodeCopy))
                }
            }
            .textCase(nil)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if searchScope == .products {
            ToolbarItemGroup(placement: .topBarLeading) {
                RouterLink(
                    "Show filters",
                    systemImage: "line.3.horizontal.decrease.circle",
                    sheet: .productFilter(initialFilter: productFilter, sections: [.category, .checkIns],
                                          onApply: { filter in
                                              productFilter = filter
                                          })
                )
                .labelStyle(.iconOnly)
            }
            if profileEnvironmentModel.hasPermission(.canAddBarcodes) {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    RouterLink(
                        "Scan a barcode",
                        systemImage: "barcode.viewfinder",
                        sheet: .barcodeScanner(onComplete: { barcode in
                            self.barcode = barcode
                            searchKey = .barcode(barcode)
                        })
                    )
                }
            }
        }
    }

    struct SearchInfo<T> {
        let values: [T]
        let searchKey: SearchKey

        var isEmpty: Bool {
            values.isEmpty
        }
    }

    struct SearchFailure {
        let message: String
    }

    enum SearchSuccess {
        case products(SearchInfo<Product.Joined>)
        case profiles(SearchInfo<Profile>)
        case locations(SearchInfo<Location>)
        case companies(SearchInfo<Company>)
    }

    enum SearchResult {
        case success(SearchSuccess)
        case failure(SearchFailure)
    }

    @ViewBuilder
    var contentUnavailableView: some View {
        switch searchResultKey {
        case let .barcode(barcode):
            ContentUnavailableView {
                Label("No Products found with the barcode", systemImage: "bubbles.and.sparkles")
            } actions: {
                Button("Create new product") {
                    router.navigate(screen: .addProduct(barcode))
                }
            }
        case let .text(searchTerm, searchScope):
            switch searchScope {
            case .companies:
                ContentUnavailableView {
                    Label("No Companies  found for \"\(searchTerm)\"", systemImage: "storefront")
                } description: {
                    Text("Check the spelling or try a new search")
                } actions: {
                    RouterLink("Create new product", screen: .addProduct(barcode))
                }
            case .locations:
                ContentUnavailableView {
                    Label("No Locations found for \"\(searchTerm)\"", systemImage: "location.magnifyingglass")
                } description: {
                    Text("Check the spelling or try a new search")
                }
            case .products:
                ContentUnavailableView {
                    Label("No Products found for \"\(searchTerm)\"", systemImage: "bubbles.and.sparkles")

                } description: {
                    Text("Check the spelling or try a new search")
                } actions: {
                    Button("Create new product") {
                        let barcodeCopy = barcode
                        barcode = nil
                        router.navigate(screen: .addProduct(barcodeCopy))
                    }
                }

            case .users:
                ContentUnavailableView {
                    Label(
                        "No profiles found for \"\(searchTerm)\"",
                        systemImage: "person.crop.circle.badge.questionmark"
                    )
                } description: {
                    Text("Check the spelling or try a new search")
                }
            }
        case nil:
            EmptyView()
        }
    }

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

    func resetBarcode() {
        barcode = nil
    }

    func addBarcodeToProduct(_ addBarcodeTo: Product.Joined) async {
        guard let barcode else { return }
        switch await repository.productBarcode.addToProduct(product: addBarcodeTo, barcode: barcode) {
        case .success:
            self.barcode = nil
            self.addBarcodeTo = nil
            showAddBarcodeConfirmation = false
            feedbackEnvironmentModel.toggle(.success("Barcode added!"))
            router.navigate(screen: .product(addBarcodeTo))
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger
                .error(
                    "adding barcode \(barcode.barcode) to product \(addBarcodeTo.id) failed. error: \(error)"
                )
        }
    }

    enum SearchScope: String, CaseIterable, Identifiable {
        var id: Self { self }
        case products, companies, users, locations

        var label: String {
            switch self {
            case .products:
                "Products"
            case .companies:
                "Companies"
            case .users:
                "Users"
            case .locations:
                "Locations"
            }
        }

        var prompt: String {
            switch self {
            case .products:
                "Search products, brands..."
            case .users:
                "Search users"
            case .companies:
                "Search companies"
            case .locations:
                "Search locations"
            }
        }
    }

    enum SearchKey: Hashable, Identifiable {
        case barcode(Barcode)
        case text(searchTerm: String, searchScope: SearchScope)

        var id: String {
            switch self {
            case let .barcode(barcode):
                "barcode::id\(barcode.id)"
            case let .text(searchTerm, searchScope):
                "text::scope:\(searchScope.rawValue)::search_term:\(searchTerm)"
            }
        }
    }
}
