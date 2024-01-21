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
    let checkInImages = [CheckIn.Image]()
    let isLoadingCheckInImages = false
    let loadMoreImages: () -> Void
    let onRefreshCheckIns: () -> Void
    @Binding var isOnWishlist: Bool

    var body: some View {
        VStack {
            ProductItemView(product: product, extras: [.companyLink, .logoOnRight])
            SummaryView(summary: summary).padding(.top, 4)
            ProductScreenActionSection(
                isOnWishlist: $isOnWishlist,
                product: product,
                onRefreshCheckIns: onRefreshCheckIns
            )
            if !checkInImages.isEmpty {
                ProfileCheckInImagesSection(
                    checkInImages: checkInImages,
                    isLoading: isLoadingCheckInImages,
                    onLoadMore: loadMoreImages
                )
            }
        }.padding(.horizontal)
    }
}
