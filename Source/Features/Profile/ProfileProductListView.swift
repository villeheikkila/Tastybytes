import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileProductListView: View {
    private let logger = Logger(category: "ProfileProductListView")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var products: [Product.Joined] = []
    @State private var searchTerm = ""
    @State private var productFilter: Product.Filter?
    @State private var initialDataLoaded = false
    @State private var alertError: AlertError?

    let profile: Profile
    let locked: Bool

    init(profile: Profile, locked: Bool, productFilter: Product.Filter? = nil) {
        self.profile = profile
        self.locked = locked
        _productFilter = State(initialValue: productFilter)
    }

    var navigationTitle: String {
        if locked {
            let subcategoryName = productFilter?.subcategory?.name
            let categoryName = productFilter?.category?.name
            if let subcategoryName, let categoryName {
                return "\(categoryName): \(subcategoryName)"
            } else if let categoryName {
                return categoryName
            } else if (productFilter?.onlyUnrated) == true {
                return "Unrated"
            } else if let rating = productFilter?.rating {
                return "Rating: \(String(format: "%.1f", rating))"
            } else {
                return "Top Entries"
            }
        }
        return initialDataLoaded ? "Products (\(filteredProducts.count))" : "Products"
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
        case let (lhs?, rhs?): sortBy == .lowestRated ? lhs < rhs : lhs > rhs
        case (nil, _): false
        case (_?, nil): true
        }
    }

    var body: some View {
        List(filteredProducts) { product in
            RouterLink(screen: .product(product)) {
                ProductItemView(product: product, extras: [.rating])
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .overlay {
            if let productFilter, !locked {
                ProductFilterOverlayView(filters: productFilter, onReset: {
                    self.productFilter = nil
                })
            }
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            toolbarContent
        }
        .alertError($alertError)
        .task {
            if !initialDataLoaded {
                await loadProducts()
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if !locked {
            ToolbarItemGroup(placement: .topBarTrailing) {
                RouterLink(
                    "Show filters",
                    systemImage: "line.3.horizontal.decrease.circle",
                    sheet: .productFilter(initialFilter: productFilter, sections: [.category, .sortBy],
                                          onApply: { filter in productFilter = filter })
                )
                .labelStyle(.iconOnly)
            }
        }
    }

    func filterProduct(_ product: Product.Joined) -> Bool {
        let ratingPass = if let ratingFilter = productFilter?.rating {
            if let averageRating = product.averageRating {
                round(averageRating * 2) / 2 == ratingFilter
            } else {
                false
            }
        } else {
            true
        }

        let onlyUnratedPass = if (productFilter?.onlyUnrated) == true {
            product.averageRating == 0 || product.averageRating == nil
        } else {
            true
        }

        let namePass = !searchTerm.isEmpty ?
            [product.getDisplayName(.brandOwner), product.getDisplayName(.fullName)].joinOptionalSpace()
            .contains(searchTerm) : true

        let categoryPass = productFilter != nil && productFilter?.category?.id != nil ? product.category
            .id == productFilter?.category?.id : true

        let subcategoryPass = productFilter != nil && productFilter?.subcategory?.id != nil ? product.subcategories
            .map(\.id)
            .contains(productFilter?.subcategory?.id ?? -1) : true

        return onlyUnratedPass && ratingPass && namePass && categoryPass && subcategoryPass
    }

    func loadProducts() async {
        switch await repository.product.getByProfile(id: profile.id) {
        case let .success(products):
            withAnimation {
                self.products = products
                initialDataLoaded = true
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Error occured while loading products. Error: \(error) (\(#file):\(#line))")
        }
    }
}
