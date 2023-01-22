import SwiftUI

struct SearchTabView: View {
  @ObservedObject var viewModel = ViewModel()
  @Binding var resetNavigationStackOnTab: Tab?
  @EnvironmentObject private var toastManager: ToastManager
  @EnvironmentObject private var profileManager: ProfileManager
  @State private var showAddBarcodeConfirmation = false
  @StateObject private var router = Router()
  @State private var scrollProxy: ScrollViewProxy?
  private let topAnchor = "top"

  var body: some View {
    NavigationStack(path: $router.path) {
      WithRoutes {
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
            }
          }
          .onAppear {
            scrollProxy = proxy
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
          .sheet(isPresented: $viewModel.showBarcodeScanner) {
            NavigationStack {
              BarcodeScannerSheetView(onComplete: {
                barcode in viewModel.searchProductsByBardcode(barcode)
              })
              .presentationDetents([.medium])
            }
          }
          .searchable(text: $viewModel.searchTerm, tokens: $viewModel.tokens) { token in
            switch token {
            case .chips: Text("Chips")
            case .candy: Text("Candy")
            case .chewingGum: Text("Chewing Gum")
            case .fruit: Text("Fruit")
            case .popcorn: Text("Popcorn")
            case .ingredient: Text("Ingredient")
            case .beverage: Text("Beverage")
            case .convenienceFood: Text("Convenience Food")
            case .cheese: Text("Cheese")
            case .snacks: Text("Snacks")
            case .juice: Text("Juice")
            case .chocolate: Text("Chocolate")
            case .cocoa: Text("Cocoa")
            case .iceCream: Text("Ice Cream")
            case .pizza: Text("Pizza")
            case .protein: Text("Protein")
            case .milk: Text("Milk")
            case .alcoholicBeverage: Text("Alcoholic Beverage")
            case .cereal: Text("Cereal")
            case .pastry: Text("Pastry")
            case .spice: Text("Spice")
            case .noodles: Text("Noodles")
            case .tea: Text("Tea")
            case .coffee: Text("Coffee")
            }
          }
          .searchScopes($viewModel.searchScope) {
            Text("Products").tag(SearchScope.products)
            Text("Companies").tag(SearchScope.companies)
            Text("Users").tag(SearchScope.users)
          }
          .onSubmit(of: .search) {
            viewModel.search()
          }
          .navigationTitle("Search")
          .toolbar {
            toolbarContent
          }
          .onChange(of: $resetNavigationStackOnTab.wrappedValue) { tab in
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
                  }
                }
              }
            } else {
              router.reset()
            }
            resetNavigationStackOnTab = nil
          }
        }
      }
    }
  }

  var profileResults: some View {
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

  var companyResults: some View {
    ForEach(viewModel.companies, id: \.self) { company in
      NavigationLink(value: Route.company(company)) {
        Text(company.name)
      }
      .id(company.id)
    }
  }

  var productResults: some View {
    ForEach(viewModel.products, id: \.id) { product in
      if viewModel.barcode == nil || product.barcodes.contains(where: { $0.isBarcode(viewModel.barcode) }) {
        NavigationLink(value: Route.product(product)) {
          ProductListItemView(product: product)
        }
        .id(product.id)
      } else {
        Button(action: {
          showAddBarcodeConfirmation.toggle()
        }) {
          ProductListItemView(product: product)
        }.buttonStyle(.plain)
          .confirmationDialog("Are you sure you want to add the barcode to product \(product.id)",
                              isPresented: $showAddBarcodeConfirmation) {
            Button("Add barcode", action: {
              viewModel.addBarcodeToProduct(product, onComplete: {
                toastManager.toggle(.success("Barcode added!"))
              })
            })
          }
      }
    }
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: {
        viewModel.showBarcodeScanner.toggle()
      }) {
        Image(systemName: "barcode.viewfinder")
      }
    }
  }
}

extension SearchTabView {
  @MainActor class ViewModel: ObservableObject {
    @Published var searchTerm: String = "" {
      didSet {
        if let firstPartOfSearchString = searchTerm.lowercased().split(separator: " ", maxSplits: 1)
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
    @Published var showBarcodeScanner = false
    @Published var isSearched = false
    @Published var searchScope: SearchScope = .products
    @Published var barcode: Barcode?
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
      if let barcode {
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
      Task {
        let currentUserId = await repository.auth.getCurrentUserId()

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
}
