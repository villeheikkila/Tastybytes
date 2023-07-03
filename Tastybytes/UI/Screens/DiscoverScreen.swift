import OSLog
import SwiftUI

struct DiscoverScreen: View {
    private let logger = Logger(category: "SearchListView")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackManager.self) private var feedbackManager
    @Environment(ProfileManager.self) private var profileManager
    @Environment(SplashScreenManager.self) private var splashScreenManager
    @State private var scrollProxy: ScrollViewProxy?
    @State private var searchTerm: String = ""
    @State private var products = [Product.Joined]()
    @State private var profiles = [Profile]()
    @State private var companies = [Company]()
    @State private var locations = [Location]()
    @State private var isSearched = false
    @State private var searchScope: SearchScope = .products
    @State private var barcode: Barcode?
    @State private var addBarcodeTo: Product.Joined? {
        didSet {
            showAddBarcodeConfirmation = true
        }
    }

    @State private var showAddBarcodeConfirmation = false
    @State private var productFilter: Product.Filter? {
        didSet {
            Task { await search() }
        }
    }

    @Binding private var scrollToTop: Int

    init(scrollToTop: Binding<Int>) {
        _scrollToTop = scrollToTop
    }

    var body: some View {
        ScrollViewReader { proxy in
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
            .disableAutocorrection(true)
            .onAppear {
                scrollProxy = proxy
            }
            .onSubmit(of: .search) {
                Task { await search() }
            }
            .onChange(of: searchScope) {
                Task { await search() }
                barcode = nil
            }
            .onChange(of: searchTerm, debounceTime: 0.2) { _ in
                Task { await search() }
            }
            .onChange(of: searchTerm) { _, term in
                if term.isEmpty {
                    Task { await resetSearch() }
                }
            }
        }
        .navigationTitle("Discover")
        .task {
            await splashScreenManager.dismiss()
        }
        .toolbar {
            toolbarContent
        }
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
                    AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
                    VStack {
                        HStack {
                            Text(profile.preferredName)
                            Spacer()
                        }
                    }
                }
                .padding([.top, .bottom], 10)
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
        if barcode != nil {
            Section {
                Text(
                    """
                    \(products.isEmpty ? "No results were found" : "If none of the results match"),\
                    you can assign the barcode to a product by searching again \
                    with the name or by creating a new product.
                    """
                )
                Button("Dismiss barcode", action: { resetBarcode() })
            }
        }

        if currentScopeIsEmpty {
            Section("Feeds") {
                Group {
                    RouterLink(
                        Product.FeedType.trending.label,
                        systemSymbol: .chartLineUptrendXyaxis,
                        screen: .productFeed(.trending)
                    )
                    RouterLink(
                        Product.FeedType.topRated.label,
                        systemSymbol: .lineHorizontalStarFillLineHorizontal,
                        screen: .productFeed(.topRated)
                    )
                    RouterLink(
                        Product.FeedType.latest.label,
                        systemSymbol: .boltHorizontalCircle,
                        screen: .productFeed(.latest)
                    )
                }
                .bold()
            }.headerProminence(.increased)
        } else {
            ForEach(products) { product in
                ProductItemView(product: product, extras: [.checkInCheck, .rating])
                    .swipeActions {
                        RouterLink("Check-in", systemSymbol: .plus, sheet: .newCheckIn(product, onCreation: { checkIn in
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
        if isSearched, profileManager.hasPermission(.canCreateProducts) {
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
                    systemSymbol: .line3HorizontalDecreaseCircle,
                    sheet: .productFilter(initialFilter: productFilter, sections: [.category, .checkIns],
                                          onApply: { filter in
                                              productFilter = filter
                                          })
                )
                .labelStyle(.iconOnly)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if profileManager.hasPermission(.canAddBarcodes) {
                    RouterLink(
                        "Scan a barcode",
                        systemSymbol: .barcodeViewfinder,
                        sheet: .barcodeScanner(onComplete: { barcode in
                            Task { await searchProductsByBardcode(barcode) }
                        })
                    )
                }
            }
        }
    }

    func resetSearch() async {
        do {
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            withAnimation {
                profiles = []
                products = []
                companies = []
                locations = []
                isSearched = false
            }
        } catch { logger.error("timer failed") }
    }

    var currentScopeIsEmpty: Bool {
        switch searchScope {
        case .companies:
            companies.isEmpty
        case .locations:
            locations.isEmpty
        case .products:
            products.isEmpty && addBarcodeTo == nil && !isSearched
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
            feedbackManager.toggle(.success("Barcode added!"))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger
                .error(
                    "adding barcode \(barcode.barcode) to product \(addBarcodeTo.id) failed. error: \(error)"
                )
        }
    }

    func searchProducts() async {
        switch await repository.product.search(searchTerm: searchTerm, filter: productFilter) {
        case let .success(searchResults):
            withAnimation {
                products = searchResults
            }
            isSearched = true
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("searching products failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchProfiles() async {
        switch await repository.profile.search(searchTerm: searchTerm, currentUserId: nil) {
        case let .success(searchResults):
            withAnimation {
                profiles = searchResults
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("searching profiles failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchProductsByBardcode(_ barcode: Barcode) async {
        switch await repository.product.search(barcode: barcode) {
        case let .success(searchResults):
            self.barcode = barcode
            await MainActor.run {
                withAnimation {
                    products = searchResults
                    isSearched = true
                }
            }
            if searchResults.count == 1, let result = searchResults.first {
                router.fetchAndNavigateTo(repository, .productWithBarcode(id: result.id, barcode: barcode))
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger
                .error("searching products with barcode \(barcode.barcode) failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchCompanies() async {
        switch await repository.company.search(searchTerm: searchTerm) {
        case let .success(searchResults):
            await MainActor.run {
                withAnimation {
                    companies = searchResults
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("searching companies failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchLocations() async {
        switch await repository.location.search(searchTerm: searchTerm) {
        case let .success(searchResults):
            withAnimation {
                locations = searchResults
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger.error("searching locations failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func search() async {
        if searchTerm.count < 2 { return }
        switch searchScope {
        case .products:
            await searchProducts()
        case .companies:
            await searchCompanies()
        case .users:
            await searchProfiles()
        case .locations:
            await searchLocations()
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
}
