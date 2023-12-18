import Components
import EnvironmentModels
import Models
import OSLog
import SwiftUI

struct ProductActionSection: View {
    private let logger = Logger(category: "ProductActionSection")
    @Environment(\.repository) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Binding var isOnWishlist: Bool

    let product: Product.Joined
    let onRefreshCheckIns: () async -> Void

    var body: some View {
        HStack(spacing: 0) {
            RouterLink(
                "Check-in!",
                systemImage: "checkmark.circle",
                sheet: .newCheckIn(product, onCreation: { _ in
                    await onRefreshCheckIns()
                }),
                asTapGesture: true
            )
            .frame(maxWidth: .infinity)
            .padding(.all, 6.5)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(4, corners: [.topLeft, .bottomLeft])
            ProgressButton("Wishlist", systemImage: "star", actionOptions: []) {
                await toggleWishlist()
            }
            .symbolVariant(isOnWishlist ? .fill : .none)
            .frame(maxWidth: .infinity)
            .padding(.all, 6)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(3, corners: [.topRight, .bottomRight])
        }.padding(.top, 4)
    }

    func toggleWishlist() async {
        if isOnWishlist {
            switch await repository.product.removeFromWishlist(productId: product.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                await MainActor.run {
                    withAnimation {
                        isOnWishlist = false
                    }
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                logger.error("removing from wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            switch await repository.product.addToWishlist(productId: product.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                await MainActor.run {
                    withAnimation {
                        isOnWishlist = true
                    }
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                logger.error("adding to wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
