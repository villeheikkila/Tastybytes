import SwiftUI

struct SearchListView: View {
  private let logger = getLogger(category: "SearchListView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var profileManager: ProfileManager
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
        if currentScopeIsEmpty {
          searchScopeList
        }
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
      .onAppear {
        scrollProxy = proxy
      }
      .listStyle(.plain)
      .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                  prompt: searchScope.prompt)
      .disableAutocorrection(true)
      .searchScopes($searchScope) {
        ForEach(SearchScope.allCases) { scope in
          Text(scope.label).tag(scope)
        }
      }
      .onSubmit(of: .search) {
        Task { await search() }
      }
      .onChange(of: searchScope, perform: { _ in
        Task { await search() }
        barcode = nil
      })
      .onChange(of: searchTerm, debounceTime: 0.2) { _ in
        Task { await search() }
      }
      .onChange(of: searchTerm, perform: { term in
        if term.isEmpty {
          Task { await resetSearch() }
        }
      })
    }
    .navigationTitle("Discover")
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
    .onChange(of: scrollToTop) { _ in
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

  private var searchScopeList: some View {
    Section("Search") {
      Group {
        Button("Products", systemImage: "grid", action: { searchScope = .products })
        Button("Companies", systemImage: "network", action: { searchScope = .companies })
        Button("Users", systemImage: "person", action: { searchScope = .users })
        Button("Locations", systemImage: "location", action: { searchScope = .locations })
      }
      .bold()
    }.headerProminence(.increased)
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
      }
      .id(profile.id)
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
    ToolbarItemGroup(placement: .navigationBarLeading) {
      if searchScope == .products {
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
    }
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      if profileManager.hasPermission(.canAddBarcodes) {
        RouterLink("Scan a barcode", systemImage: "barcode.viewfinder", sheet: .barcodeScanner(onComplete: { barcode in
          Task { await searchProductsByBardcode(barcode) }
        }))
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
      return companies.isEmpty
    case .locations:
      return locations.isEmpty
    case .products:
      return products.isEmpty && addBarcodeTo == nil && !isSearched
    case .users:
      return profiles.isEmpty
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
      feedbackManager.toggle(.error(.unexpected))
      logger.error("adding barcode \(barcode.barcode) to product \(addBarcodeTo.id) failed: \(error.localizedDescription)")
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
      feedbackManager.toggle(.error(.unexpected))
      logger.error("searching products failed: \(error.localizedDescription)")
    }
  }

  func searchProfiles() async {
    switch await repository.profile.search(searchTerm: searchTerm, currentUserId: nil) {
    case let .success(searchResults):
      withAnimation {
        profiles = searchResults
      }
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("searching profiles failed: \(error.localizedDescription)")
    }
  }

  func searchProductsByBardcode(_ barcode: Barcode) async {
    switch await repository.product.search(barcode: barcode) {
    case let .success(searchResults):
      self.barcode = barcode
      withAnimation {
        products = searchResults
      }
      isSearched = true
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("searching products with barcode \(barcode.barcode) failed: \(error.localizedDescription)")
    }
  }

  func searchCompanies() async {
    switch await repository.company.search(searchTerm: searchTerm) {
    case let .success(searchResults):
      withAnimation {
        companies = searchResults
      }
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("searching companies failed: \(error.localizedDescription)")
    }
  }

  func searchLocations() async {
    switch await repository.location.search(searchTerm: searchTerm) {
    case let .success(searchResults):
      withAnimation {
        locations = searchResults
      }
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("searching locations failed: \(error.localizedDescription)")
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
        return "Products"
      case .companies:
        return "Companies"
      case .users:
        return "Users"
      case .locations:
        return "Locations"
      }
    }

    var prompt: String {
      switch self {
      case .products:
        return "Search products, brands..."
      case .users:
        return "Search users"
      case .companies:
        return "Search companies"
      case .locations:
        return "Search locations"
      }
    }
  }
}
