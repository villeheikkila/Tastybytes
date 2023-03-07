import SwiftUI

extension DiscoverTab {
  enum Sheet: Identifiable {
    var id: Self { self }
    case checkIn
    case barcodeScanner
    case filters
  }

  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "SearchTab")
    let client: Client
    @Published var searchTerm: String = ""
    @Published var products = [Product.Joined]()
    @Published var profiles = [Profile]()
    @Published var companies = [Company]()
    @Published var locations = [Location]()
    @Published var isSearched = false
    @Published var searchScope: SearchScope = .products
    @Published var barcode: Barcode?
    @Published var addBarcodeTo: Product.Joined? {
      didSet {
        showAddBarcodeConfirmation = true
      }
    }

    @Published var showAddBarcodeConfirmation = false
    @Published var productFilter: Product.Filter?
    @Published var checkInProduct: Product.Joined? {
      didSet {
        activeSheet = .checkIn
      }
    }

    @Published var activeSheet: Sheet?

    init(_ client: Client) {
      self.client = client
    }

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
          switch await client.productBarcode.addToProduct(product: addBarcodeTo, barcode: barcode) {
          case .success:
            self.barcode = nil
            self.addBarcodeTo = nil
            self.showAddBarcodeConfirmation = false
            onComplete()
          case let .failure(error):
            logger
              .error(
                "adding barcode \(barcode.barcode) to product \(addBarcodeTo.id) failed: \(error.localizedDescription)"
              )
          }
        }
      }
    }

    func searchProducts() {
      Task {
        switch await client.product.search(searchTerm: searchTerm, filter: productFilter) {
        case let .success(searchResults):
          withAnimation {
            self.products = searchResults
          }
          self.isSearched = true
        case let .failure(error):
          logger
            .error(
              """
                "searching products with \(self.searchTerm)\
                failed: \(error.localizedDescription)
              """
            )
        }
      }
    }

    func searchProfiles() {
      Task {
        switch await client.profile.search(searchTerm: searchTerm, currentUserId: nil) {
        case let .success(searchResults):
          withAnimation {
            self.profiles = searchResults
          }
        case let .failure(error):
          logger
            .error(
              "searching profiles with search term \(self.searchTerm) failed: \(error.localizedDescription)"
            )
        }
      }
    }

    func searchProductsByBardcode(_ barcode: Barcode) {
      Task {
        switch await client.product.search(barcode: barcode) {
        case let .success(searchResults):
          self.barcode = barcode
          withAnimation {
            self.products = searchResults
          }
          self.isSearched = true
        case let .failure(error):
          logger
            .error(
              """
              searching products with barcode \(barcode.barcode) failed:\
                \(error.localizedDescription)
              """
            )
        }
      }
    }

    func searchCompanies() {
      Task {
        switch await client.company.search(searchTerm: searchTerm) {
        case let .success(searchResults):
          withAnimation {
            self.companies = searchResults
          }
        case let .failure(error):
          logger
            .error(
              "searching companies with search term \(self.searchTerm) failed: \(error.localizedDescription)"
            )
        }
      }
    }

    func searchLocations() {
      Task {
        switch await client.location.search(searchTerm: searchTerm) {
        case let .success(searchResults):
          withAnimation {
            self.locations = searchResults
          }
        case let .failure(error):
          logger
            .error(
              "searching locations with search term \(self.searchTerm) failed: \(error.localizedDescription)"
            )
        }
      }
    }

    func search() {
      if searchTerm.count < 2 { return }

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
