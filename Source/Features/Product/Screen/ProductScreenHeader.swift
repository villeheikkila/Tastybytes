import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ProductScreenHeader: View {
    let product: Product.Joined
    let summary: Summary?
    let checkInImages: [ImageEntity.JoinedCheckIn]
    let isLoadingCheckInImages = false
    let loadMoreImages: @MainActor () -> Void
    let onCreateCheckIn: @MainActor (_ checkIn: CheckIn) async -> Void
    @Binding var isOnWishlist: Bool

    var productItemViewExtras: Set<ProductItemView.Extra> {
        product.logos.isEmpty ? [.companyLink] : [.companyLink, .logoOnRight]
    }

    var body: some View {
        ProductItemView(product: product, extras: productItemViewExtras)
        ProductScreenActionSection(
            isOnWishlist: $isOnWishlist,
            product: product,
            onCreateCheckIn: onCreateCheckIn
        )
        SummaryView(summary: summary)
        if !checkInImages.isEmpty {
            CheckInImagesSection(
                checkInImages: checkInImages,
                isLoading: isLoadingCheckInImages,
                onLoadMore: loadMoreImages
            )
        }
    }
}
