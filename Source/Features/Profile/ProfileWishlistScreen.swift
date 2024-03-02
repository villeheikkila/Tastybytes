import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ProfileWishlistScreen: View {
    private let logger = Logger(category: "ProfileWishlistScreen")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var products: [Product.Joined] = []
    @State private var searchTerm = ""
    @State private var initialDataLoaded = false
    @State private var alertError: AlertError?

    let profile: Profile

    init(profile: Profile) {
        self.profile = profile
    }

    var isEmpty: Bool {
        initialDataLoaded && products.isEmpty
    }

    var body: some View {
        List(products) { product in
            RouterLink(screen: .product(product)) {
                ProductItemView(product: product, extras: [.rating])
            }
            .swipeActions(allowsFullSwipe: true) {
                ProgressButton(
                    "labels.delete",
                    systemImage: "xmark",
                    role: .destructive,
                    action: {
                        await removeFromWishlist(product: product)
                    }
                )
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .refreshable {
            await loadProducts()
        }
        .background {
            if isEmpty {
                ContentUnavailableView {
                    Label("wishlist.empty.title", systemImage: "list.star")
                }
            }
        }
        .navigationTitle("wishlist.navigationTitle")
        .alertError($alertError)
        .task {
            if !initialDataLoaded {
                await loadProducts()
            }
        }
    }

    func removeFromWishlist(product: Product.Joined) async {
        switch await repository.product.removeFromWishlist(productId: product.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            withAnimation {
                products.remove(object: product)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Removing from wishlist failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func loadProducts() async {
        switch await repository.product.getWishlistItems(profileId: profile.id) {
        case let .success(wishlist):
            withAnimation {
                products = wishlist.map(\.product)
                initialDataLoaded = true
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger
                .error(
                    "Error occured while loading wishlist items. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}
