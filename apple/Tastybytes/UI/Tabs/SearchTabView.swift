import SwiftUI

struct SearchTabView: View {
  @ObservedObject var viewModel = ViewModel()
  @Binding var resetNavigationOnTab: Tab?
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var router = Router()
  @State private var scrollProxy: ScrollViewProxy?

  private let topAnchor = "top"

  var body: some View {
    NavigationStack(path: $router.path) {
      ScrollViewReader { proxy in
        List {
          switch viewModel.searchScope {
          case .products:
            productResults
            if viewModel.isSearched {
              if viewModel.barcode != nil {
                Section {
                  Text(
                    """
                    \(viewModel.products.isEmpty ? "No results were found" : "If none of the results match"),\
                    you can assign the barcode to a product by searching again\
                    with the name or by creating a new product.
                    """
                  )
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
          case .locations:
            locationResults
          }
        }
        .onAppear {
          scrollProxy = proxy
        }
        .listStyle(.grouped)
        .onChange(of: viewModel.searchScope, perform: { _ in
          viewModel.search()
          viewModel.barcode = nil
        })
        .onChange(of: viewModel.searchTerm, perform: {
          term in
          if term.isEmpty {
            viewModel.resetSearch()
          }
        })
        .sheet(isPresented: $viewModel.showBarcodeScanner) {
          NavigationStack {
            BarcodeScannerSheetView(onComplete: {
              barcode in viewModel.searchProductsByBardcode(barcode)
            })
          }
          .presentationDetents([.medium])
        }
        .searchable(text: $viewModel.searchTerm, tokens: $viewModel.tokens,
                    prompt: viewModel.searchScope.prompt) { token in
          Text(token.label)
        }
        .disableAutocorrection(true)
        .searchScopes($viewModel.searchScope) {
          ForEach(SearchScope.allCases) { scope in
            Text(scope.label).tag(scope)
          }
        }
        .onSubmit(of: .search) {
          viewModel.search()
        }
        .navigationTitle("Search")
        .toolbar {
          toolbarContent
        }
        .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
          if tab == .search {
            if router.path.isEmpty {
              withAnimation {
                switch viewModel.searchScope {
                case .products:
                  if let id = viewModel.products.first?.id {
                    scrollProxy?.scrollTo(id, anchor: .top)
                  }
                case .companies:
                  if let id = viewModel.companies.first?.id {
                    scrollProxy?.scrollTo(id, anchor: .top)
                  }
                case .users:
                  if let id = viewModel.profiles.first?.id {
                    scrollProxy?.scrollTo(id, anchor: .top)
                  }
                case .locations:
                  if let id = viewModel.locations.first?.id {
                    scrollProxy?.scrollTo(id, anchor: .top)
                  }
                }
              }
            }
          } else {
            router.reset()
          }
          resetNavigationOnTab = nil
        }
      }
      .withRoutes()
    }
    .environmentObject(router)
  }

  private var profileResults: some View {
    ForEach(viewModel.profiles, id: \.self) { profile in
      NavigationLink(value: Route.profile(profile)) {
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
      .id(profile.id)
    }
  }

  private var companyResults: some View {
    ForEach(viewModel.companies, id: \.self) { company in
      NavigationLink(value: Route.company(company)) {
        Text(company.name)
      }
      .id(company.id)
    }
  }

  private var locationResults: some View {
    ForEach(viewModel.locations, id: \.self) { location in
      NavigationLink(value: Route.location(location)) {
        Text(location.name)
      }
      .id(location.id)
    }
  }

  private var productResults: some View {
    ForEach(viewModel.products, id: \.id) { product in
      if viewModel.barcode == nil || product.barcodes.contains(where: { $0.isBarcode(viewModel.barcode) }) {
        NavigationLink(value: Route.product(product)) {
          ProductItemView(product: product)
        }
        .id(product.id)
      } else {
        Button(action: {
          viewModel.addBarcodeTo = product
        }) {
          ProductItemView(product: product)
        }
        .buttonStyle(.plain)
        .confirmationDialog(
          "Add barcode confirmation",
          isPresented: $viewModel.showAddBarcodeConfirmation,
          presenting: viewModel.addBarcodeTo
        ) {
          presenting in
          Button(
            "Add barcode to \(presenting.getDisplayName(.fullName))",
            action: {
              viewModel.addBarcodeToProduct(onComplete: {
                toastManager.toggle(.success("Barcode added!"))
              })
            }
          )
        }
      }
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: {
        viewModel.showBarcodeScanner.toggle()
      }) {
        Image(systemName: "barcode.viewfinder")
      }
    }
  }

  private struct ProductItemView: View {
    let product: Product.Joined

    var body: some View {
      VStack(alignment: .leading, spacing: 3) {
        Text(product.getDisplayName(.fullName))
          .font(.system(size: 16, weight: .bold, design: .default))

        if let description = product.description {
          Text(description)
            .font(.system(size: 12, weight: .medium, design: .default))
        }

        Text(product.getDisplayName(.brandOwner))
          .font(.system(size: 14, weight: .bold, design: .default))
          .foregroundColor(.secondary)

        HStack {
          CategoryNameView(category: product.category)
          ForEach(product.subcategories, id: \.id) { subcategory in
            ChipView(title: subcategory.name, cornerRadius: 5)
          }
        }
      }
    }
  }
}

extension SearchTabView {
  @MainActor class ViewModel: ObservableObject {
    @Published var searchTerm: String = "" {
      didSet {
        if let firstPartOfSearchString = searchTerm
          .lowercased()
          .split(separator: " ", maxSplits: 1)
          .map(String.init)
          .first
        {
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
    @Published var locations = [Location]()
    @Published var showBarcodeScanner = false
    @Published var isSearched = false
    @Published var searchScope: SearchScope = .products
    @Published var barcode: Barcode?
    @Published var tokens: [Category.Name] = []
    @Published var addBarcodeTo: Product.Joined? {
      didSet {
        showAddBarcodeConfirmation = true
      }
    }

    @Published var showAddBarcodeConfirmation = false

    func resetSearch() {
      profiles = []
      products = []
      companies = []
      locations = []
    }

    func resetBarcode() {
      barcode = nil
    }

    func addBarcodeToProduct(onComplete: @escaping () -> Void) {
      if let addBarcodeTo, let barcode {
        Task {
          switch await repository.product.addBarcodeToProduct(product: addBarcodeTo, barcode: barcode) {
          case .success:
            self.barcode = nil
            self.addBarcodeTo = nil
            self.showAddBarcodeConfirmation = false
            onComplete()
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
          self.products = searchResults
          self.isSearched = true
        case let .failure(error):
          print(error)
        }
      }
    }

    func searchProfiles() {
      Task {
        switch await repository.profile.search(searchTerm: searchTerm, currentUserId: nil) {
        case let .success(searchResults):
          self.profiles = searchResults
        case let .failure(error):
          print(error)
        }
      }
    }

    func searchProductsByBardcode(_ barcode: Barcode) {
      Task {
        switch await repository.product.search(barcode: barcode) {
        case let .success(searchResults):
          self.barcode = barcode
          self.products = searchResults
          self.isSearched = true
        case let .failure(error):
          print(error)
        }
      }
    }

    func searchCompanies() {
      Task {
        switch await repository.company.search(searchTerm: searchTerm) {
        case let .success(searchResults):
          self.companies = searchResults
        case let .failure(error):
          print(error)
        }
      }
    }

    func searchLocations() {
      Task {
        switch await repository.location.search(searchTerm: searchTerm) {
        case let .success(searchResults):
          self.locations = searchResults
        case let .failure(error):
          print(error)
        }
      }
    }

    func search() {
      if searchTerm.count < 3 { return }

      switch searchScope {
      case .products:
        searchProducts()
      case .companies:
        searchCompanies()
      case .users:
        searchProfiles()
      case .locations:
        searchLocations()
      }
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