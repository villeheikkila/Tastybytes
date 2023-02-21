import SwiftUI

struct ProfileProductListView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, profile: Profile) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, profile: profile))
  }

  var body: some View {
    List {
      ForEach(viewModel.filteredProducts, id: \.id) { product in
        NavigationLink(value: Route.product(product)) {
          ProductItemView(product: product)
        }
      }
    }
    .listStyle(.grouped)
    .searchable(text: $viewModel.searchTerm)
    .navigationTitle("Products")
    .sheet(isPresented: $viewModel.showFilters) {
      NavigationStack {
        ProductFilterSheetView(
          viewModel.client,
          initialFilter: viewModel.productFilter,
          sections: [.category, .sortBy],
          onApply: { filter in
            viewModel.productFilter = filter
            viewModel.showFilters = false
          }
        )
      }
      .presentationDetents([.medium])
    }
    .if(viewModel.productFilter != nil, transform: { view in
      view.overlay {
        BottomOverlay {
          if let productFilter = viewModel.productFilter {
            ProductFilterOverlayView(filters: productFilter)
          }
        }
      }
    })
    .toolbar {
      toolbar
    }
    .task {
      await viewModel.loadProducts()
    }
  }

  @ToolbarContentBuilder
  private var toolbar: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      Button(action: { viewModel.showFilters.toggle() }) {
        Image(systemName: "line.3.horizontal.decrease.circle")
      }
    }
  }
}

extension ProfileProductListView {
  @MainActor class ViewModel: ObservableObject {
    let logger = getLogger(category: "ProfileProductListView")
    let client: Client
    let profile: Profile
    @Published var products: [Product.Joined] = []
    @Published var showFilters = false
    @Published var searchTerm = ""
    @Published var productFilter: Product.Filter?

    init(_ client: Client, profile: Profile) {
      self.client = client
      self.profile = profile
    }

    var filteredProducts: [Product.Joined] {
      let filtered = products
        .filter { filterProduct($0) }

      if let sortBy = productFilter?.sortBy {
        return filtered.sorted { sortProducts(sortBy, $0, $1) }
      } else {
        return filtered
      }
    }

    func sortProducts(_ sortBy: Product.Filter.SortBy, _ lhs: Product.Joined, _ rhs: Product.Joined) -> Bool {
      switch (lhs.averageRating, rhs.averageRating) {
      case let (lhs?, rhs?): return sortBy == .lowestRated ? lhs < rhs : lhs > rhs
      case (nil, _): return false
      case (_?, nil): return true
      }
    }

    func filterProduct(_ product: Product.Joined) -> Bool {
      let namePass = !searchTerm.isEmpty ?
        joinOptionalStrings([product.getDisplayName(.brandOwner), product.getDisplayName(.fullName)])
        .contains(searchTerm) : true

      let categoryPass = productFilter != nil && productFilter?.category?.id != nil ? product.category
        .id == productFilter?.category?.id : true
      let subcategoryPass = productFilter != nil && productFilter?.subcategory?.id != nil ? product.subcategories
        .map(\.id)
        .contains(productFilter?.subcategory?.id ?? -1) : true

      return namePass && categoryPass && subcategoryPass
    }

    func loadProducts() async {
      switch await client.product.getByProfile(id: profile.id) {
      case let .success(products):
        withAnimation {
          self.products = products
        }
      case let .failure(error):
        logger.error("error occured while loading products: \(error)")
      }
    }
  }
}
