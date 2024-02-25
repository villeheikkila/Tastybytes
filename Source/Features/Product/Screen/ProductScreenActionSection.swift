import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ProductScreenActionSection: View {
    private let logger = Logger(category: "ProductScreenActionSection")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Binding var isOnWishlist: Bool

    let product: Product.Joined
    let onCreateCheckIn: (_ checkIn: CheckIn) async -> Void

    var body: some View {
        HStack(spacing: 0) {
            RouterLink(
                "checkIn.create.label.prominent",
                systemImage: "checkmark.circle",
                sheet: .newCheckIn(product, onCreation: onCreateCheckIn),
                asTapGesture: true
            )
            .frame(maxWidth: .infinity)
            .padding(.all, 6.5)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(4, corners: [.topLeft, .bottomLeft])
            ProgressButton("wishlist.add.label", systemImage: "star", actionOptions: []) {
                await toggleWishlist()
            }
            .buttonStyle(.plain)
            .symbolVariant(isOnWishlist ? .fill : .none)
            .frame(maxWidth: .infinity)
            .padding(.all, 6)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(3, corners: [.topRight, .bottomRight])
        }
    }

    func toggleWishlist() async {
        if isOnWishlist {
            switch await repository.product.removeFromWishlist(productId: product.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                withAnimation {
                    isOnWishlist = false
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                logger.error("Removing from wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        } else {
            switch await repository.product.addToWishlist(productId: product.id) {
            case .success:
                feedbackEnvironmentModel.trigger(.notification(.success))
                withAnimation {
                    isOnWishlist = true
                }
            case let .failure(error):
                guard !error.isCancelled else { return }
                logger.error("Adding to wishlist failed. Error: \(error) (\(#file):\(#line))")
            }
        }
    }
}
