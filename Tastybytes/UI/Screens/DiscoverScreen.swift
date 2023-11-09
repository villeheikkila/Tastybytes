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
    @Environment(SplashScreenEnvironmentModel.self) private var splashScreenEnvironmentModel
    @State private var alertError: AlertError?
    @State private var scrollProxy: ScrollViewProxy?
    @State private var products = [Product.Joined]()
    @State private var profiles = [Profile]()
    @State private var companies = [Company]()
    @State private var locations = [Location]()
    @State private var isSearched = false
    @State private var isLoading = false
    @State private var searchScope: SearchScope = .products
    @State private var barcode: Barcode?
    @State private var addBarcodeTo: Product.Joined? {
        didSet {
            showAddBarcodeConfirmation = true
        }
    }

    @State private var showAddBarcodeConfirmation = false
    @State private var productFilter: Product.Filter?

    @State private var searchTerm = ""
    @State private var searchedFor = ""
    @State private var searchedBarcode: Barcode?

    @State var searchByBarcode: Barcode?
    @State var searchKey: SearchKey?

    @Binding var scrollToTop: Int

    private var showContentUnavailableView: Bool {
        (!searchedFor.isEmpty || searchedBarcode != nil) && isSearched && !isLoading && currentScopeIsEmpty
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
            searchKey = .init(searchTerm: searchTerm, searchScope: searchScope)
        }
        .onChange(of: searchScope) {
            searchKey = .init(searchTerm: searchTerm, searchScope: searchScope)
            barcode = nil
            isSearched = false
        }
        .onChange(of: productFilter) {
            searchKey = .init(searchTerm: searchTerm, searchScope: searchScope)
        }
        .onChange(of: searchTerm, debounceTime: 0.2) { _ in
            searchKey = .init(searchTerm: searchTerm, searchScope: searchScope)
        }
        .onChange(of: searchTerm) { _, term in
            if term.isEmpty {
                resetSearch()
            }
        }
        .navigationTitle("Discover")
        .task {
            await splashScreenEnvironmentModel.dismiss()
        }
        .task(id: searchKey) {
            await search()
        }
        .task(id: searchByBarcode) {
            await searchProductsByBardcode()
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

        if currentScopeIsEmpty && addBarcodeTo == nil && !isSearched {
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
        if isSearched, !showContentUnavailableView, profileEnvironmentModel.hasPermission(.canCreateProducts) {
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                if profileEnvironmentModel.hasPermission(.canAddBarcodes) {
                    RouterLink(
                        "Scan a barcode",
                        systemImage: "barcode.viewfinder",
                        sheet: .barcodeScanner(onComplete: { barcode in
                            searchByBarcode = barcode
                        })
                    )
                }
            }
        }
    }

    @ViewBuilder
    var contentUnavailableView: some View {
        switch searchScope {
        case .companies:
            ContentUnavailableView {
                Label("No Companies  found for \"\(searchedFor)\"", systemImage: "storefront")
            } description: {
                Text("Check the spelling or try a new search")
            } actions: {
                RouterLink("Create new product", screen: .addProduct(barcode))
            }
        case .locations:
            ContentUnavailableView {
                Label("No Locations found for \"\(searchedFor)\"", systemImage: "location.magnifyingglass")
            } description: {
                Text("Check the spelling or try a new search")
            }
        case .products:
            if searchedBarcode != nil {
                ContentUnavailableView {
                    Label("No Products found with the barcode", systemImage: "bubbles.and.sparkles")
                } actions: {
                    Button("Create new product") {
                        let barcodeCopy = barcode
                        barcode = nil
                        router.navigate(screen: .addProduct(barcodeCopy))
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("No Products found for \"\(searchedFor)\"", systemImage: "bubbles.and.sparkles")

                } description: {
                    Text("Check the spelling or try a new search")
                } actions: {
                    Button("Create new product") {
                        let barcodeCopy = barcode
                        barcode = nil
                        router.navigate(screen: .addProduct(barcodeCopy))
                    }
                }
            }
        case .users:
            ContentUnavailableView {
                Label("No profiles found for \"\(searchedFor)\"", systemImage: "person.crop.circle.badge.questionmark")
            } description: {
                Text("Check the spelling or try a new search")
            }
        }
    }

    func resetSearch() {
        withAnimation {
            profiles = []
            products = []
            companies = []
            locations = []
            isSearched = false
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
            await MainActor.run {
                self.barcode = nil
                self.addBarcodeTo = nil
                showAddBarcodeConfirmation = false
            }
            feedbackEnvironmentModel.toggle(.success("Barcode added!"))
            router.navigate(screen: .product(addBarcodeTo))
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
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
                isLoading = false
                searchedFor = searchTerm
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("searching products failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchProfiles() async {
        switch await repository.profile.search(searchTerm: searchTerm, currentUserId: nil) {
        case let .success(searchResults):
            withAnimation {
                profiles = searchResults
                isLoading = false
                searchedFor = searchTerm
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("searching profiles failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchProductsByBardcode() async {
        guard let searchByBarcode else { return }
        isLoading = true
        switch await repository.product.search(barcode: searchByBarcode) {
        case let .success(searchResults):
            await MainActor.run {
                withAnimation {
                    products = searchResults
                    isSearched = true
                    searchedFor = ""
                    searchedBarcode = searchByBarcode
                    isLoading = false
                }
            }
            if searchResults.count == 1, let result = searchResults.first {
                router.fetchAndNavigateTo(repository, .productWithBarcode(id: result.id, barcode: searchByBarcode))
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger
                .error(
                    "searching products with barcode failed. Error: \(error) (\(#file):\(#line))"
                )
        }
    }

    func searchCompanies() async {
        switch await repository.company.search(searchTerm: searchTerm) {
        case let .success(searchResults):
            await MainActor.run {
                withAnimation {
                    companies = searchResults
                    isLoading = false
                    searchedFor = searchTerm
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("searching companies failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchLocations() async {
        switch await repository.location.search(searchTerm: searchTerm) {
        case let .success(searchResults):
            withAnimation {
                locations = searchResults
                isLoading = false
                searchedFor = searchTerm
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("searching locations failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func search() async {
        if searchTerm.count < 2 { return }
        isLoading = true
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
        isSearched = true
        searchedBarcode = nil
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

    struct SearchKey: Hashable {
        let searchTerm: String
        let searchScope: SearchScope
    }
}
