import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileWishlistScreen: View {
    private let logger = Logger(category: "ProfileWishlistScreen")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var state: ScreenState = .loading
    @State private var products: [Product.Joined] = []
    @State private var searchTerm = ""

    let profile: Profile

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
        .overlay {
            if state == .populated {
                if products.isEmpty {
                    ContentUnavailableView {
                        Label("wishlist.empty.title", systemImage: "list.star")
                    }
                }
            } else {
                ScreenStateOverlayView(state: state, errorDescription: "") {
                    await loadProducts()
                }
            }
        }
        .navigationTitle("wishlist.navigationTitle")
        .initialTask {
            await loadProducts()
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
                state = .populated
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            if state != .populated {
                state = .error([error])
            }
            logger
                .error(
                    "Error occured while loading wishlist items. Description: \(error.localizedDescription). Error: \(error) (\(#file):\(#line))"
                )
        }
    }
}
