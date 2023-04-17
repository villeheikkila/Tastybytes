import SwiftUI

struct ProfileProductListView: View {
  let logger = getLogger(category: "ProfileProductListView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var products: [Product.Joined] = []
  @State private var searchTerm = ""
  @State private var productFilter: Product.Filter?

  let profile: Profile

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

  var body: some View {
    List {
      ForEach(filteredProducts) { product in
        RouterLink(screen: .product(product)) {
          ProductItemView(product: product, extras: [.rating])
        }
      }
    }
    .listStyle(.plain)
    .searchable(text: $searchTerm)
    .overlay {
      if let productFilter {
        ProductFilterOverlayView(filters: productFilter, onReset: {
          self.productFilter = nil
        })
      }
    }
    .navigationTitle("Products (\(filteredProducts.count))")
    .toolbar {
      toolbarContent
    }
    .task {
      await loadProducts()
    }
  }

  @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
    ToolbarItemGroup(placement: .navigationBarTrailing) {
      RouterLink(
        "Show filters",
        systemImage: "line.3.horizontal.decrease.circle",
        sheet: .productFilter(initialFilter: productFilter, sections: [.category, .sortBy],
                              onApply: { filter in productFilter = filter })
      )
      .labelStyle(.iconOnly)
    }
  }

  func filterProduct(_ product: Product.Joined) -> Bool {
    let namePass = !searchTerm.isEmpty ?
      [product.getDisplayName(.brandOwner), product.getDisplayName(.fullName)].joinOptionalSpace()
      .contains(searchTerm) : true

    let categoryPass = productFilter != nil && productFilter?.category?.id != nil ? product.category
      .id == productFilter?.category?.id : true

    let subcategoryPass = productFilter != nil && productFilter?.subcategory?.id != nil ? product.subcategories
      .map(\.id)
      .contains(productFilter?.subcategory?.id ?? -1) : true

    return namePass && categoryPass && subcategoryPass
  }

  func loadProducts() async {
    switch await repository.product.getByProfile(id: profile.id) {
    case let .success(products):
      withAnimation {
        self.products = products
      }
    case let .failure(error):
      feedbackManager.toggle(.error(.unexpected))
      logger.error("error occured while loading products: \(error)")
    }
  }
}
