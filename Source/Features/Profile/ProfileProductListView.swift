
import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct ProfileProductListView: View {
    private let logger = Logger(label: "ProfileProductListView")
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var products: [Product.Joined] = []
    @State private var searchTerm = ""
    @State private var productFilter: Product.Filter?

    let profile: Profile.Saved
    let locked: Bool

    init(profile: Profile.Saved, locked: Bool, productFilter: Product.Filter? = nil) {
        self.profile = profile
        self.locked = locked
        _productFilter = State(initialValue: productFilter)
    }

    private var navigationTitle: LocalizedStringKey {
        if locked {
            let subcategoryName = productFilter?.subcategory?.name
            let categoryName = productFilter?.category?.name
            if let subcategoryName, let categoryName {
                return "\(categoryName): \(subcategoryName)"
            } else if let categoryName {
                return .init(stringLiteral: categoryName)
            } else if (productFilter?.onlyUnrated) == true {
                return "profileProductList.unrated.navigationTitle"
            } else if let rating = productFilter?.rating {
                return "profileProductList.rated.navigationTitle \(rating.formatted(.number.precision(.fractionLength(1))))"
            } else {
                return "rating.topEntries.label"
            }
        }
        return state.isPopulated ? "profileProductList.navigationTitle \(filteredProducts.count.formatted())" : "profileProductList.navigationTitle"
    }

    private var filteredProducts: [Product.Joined] {
        let filtered = products
            .filter { filterProduct($0) }

        if let sortBy = productFilter?.sortBy {
            return filtered.sorted { sortProducts(sortBy, $0, $1) }
        } else {
            return filtered
        }
    }

    private func sortProducts(_ sortBy: Product.Filter.SortBy, _ lhs: Product.Joined, _ rhs: Product.Joined) -> Bool {
        switch (lhs.averageRating, rhs.averageRating) {
        case let (lhs?, rhs?): sortBy == .lowestRated ? lhs < rhs : lhs > rhs
        case (nil, _): false
        case (_?, nil): true
        }
    }

    var body: some View {
        List(filteredProducts) { product in
            ProductListRowView(product: product)
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .safeAreaInset(edge: .top, content: {
            if let productFilter, !locked {
                ProductFilterOverlayView(filters: productFilter, onReset: {
                    self.productFilter = nil
                })
            }
        })
        .overlay {
            ScreenStateOverlayView(state: state) {
                await loadProducts()
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await loadProducts()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if !locked {
            ToolbarItemGroup(placement: .topBarTrailing) {
                RouterLink(
                    "profileProductList.filters.show.label",
                    systemImage: "line.3.horizontal.decrease.circle",
                    open: .sheet(.productFilter(initialFilter: productFilter, sections: [.category, .sortBy],
                                                onApply: { filter in productFilter = filter }))
                )
                .labelStyle(.iconOnly)
            }
        }
    }

    private func filterProduct(_ product: Product.Joined) -> Bool {
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
            [product.formatted(.brandOwner), product.formatted(.fullName)].joinOptionalSpace()
            .localizedCaseInsensitiveContains(searchTerm) : true

        let categoryPass = productFilter != nil && productFilter?.category?.id != nil ? product.category
            .id == productFilter?.category?.id : true

        let subcategoryPass = productFilter != nil && productFilter?.subcategory?.id != nil ? product.subcategories
            .map(\.id)
            .contains(productFilter?.subcategory?.id ?? -1) : true

        return onlyUnratedPass && ratingPass && namePass && categoryPass && subcategoryPass
    }

    private func loadProducts() async {
        do {
            let products = try await repository.product.getByProfile(id: profile.id)
            withAnimation {
                self.products = products
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            if state != .populated {
                state = .error(error)
            }
            logger.error("Error occured while loading products. Error: \(error) (\(#file):\(#line))")
        }
    }
}
