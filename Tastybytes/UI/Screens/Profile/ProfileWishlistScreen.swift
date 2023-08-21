import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileWishlistScreen: View {
    private let logger = Logger(category: "ProfileWishlistScreen")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackManager.self) private var feedbackManager
    @State private var products: [Product.Joined] = []
    @State private var searchTerm = ""
    @State private var initialDataLoaded = false

    let profile: Profile

    init(profile: Profile) {
        self.profile = profile
    }

    var isEmpty: Bool {
        initialDataLoaded && products.isEmpty
    }

    var body: some View {
        List {
            ForEach(products) { product in
                RouterLink(screen: .product(product)) {
                    ProductItemView(product: product, extras: [.rating])
                }
                .swipeActions(allowsFullSwipe: true) {
                    ProgressButton(
                        "Delete",
                        systemSymbol: .xmark,
                        role: .destructive,
                        action: {
                            await removeFromWishlist(product: product)
                        }
                    )
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .background {
            if isEmpty {
                ContentUnavailableView {
                    Label("Wishlist is empty", systemSymbol: .listStar)
                }
            }
        }
        .navigationTitle("Wishlist")
        .refreshable {
            await loadProducts()
        }
        .task {
            if !initialDataLoaded {
                await loadProducts()
            }
        }
    }

    func removeFromWishlist(product: Product.Joined) async {
        switch await repository.product.removeFromWishlist(productId: product.id) {
        case .success:
            feedbackManager.trigger(.notification(.success))
            await MainActor.run {
                withAnimation {
                    products.remove(object: product)
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            logger.error("removing from wishlist failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func loadProducts() async {
        switch await repository.product.getWishlistItems(profileId: profile.id) {
        case let .success(wishlist):
            await MainActor.run {
                withAnimation {
                    self.products = wishlist.map(\.product)
                    initialDataLoaded = true
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackManager.toggle(.error(.unexpected))
            logger
                .error(
                    "Error occured while loading wishlist items. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}
