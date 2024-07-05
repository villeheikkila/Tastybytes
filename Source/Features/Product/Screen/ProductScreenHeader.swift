import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct ProductScreenHeader: View {
    let product: Product.Joined
    let summary: Summary?
    let checkInImages: [ImageEntity.JoinedCheckIn]
    let isLoadingCheckInImages = false
    let loadMoreImages: () -> Void
    let onCreateCheckIn: (_ checkIn: CheckIn) async -> Void

    var productItemViewExtras: Set<ProductEntityView.Extra> {
        product.logos.isEmpty ? [.companyLink] : [.companyLink, .logoOnRight]
    }

    var body: some View {
        ProductEntityView(product: product, extras: productItemViewExtras)
        CreateCheckInButtonView(
            product: product,
            onCreateCheckIn: onCreateCheckIn
        )
        if let summary, !summary.isEmpty {
            SummaryView(summary: summary)
        }
        if !checkInImages.isEmpty {
            CheckInImagesSection(
                checkInImages: checkInImages,
                isLoading: isLoadingCheckInImages,
                onLoadMore: loadMoreImages
            )
        }
    }
}
