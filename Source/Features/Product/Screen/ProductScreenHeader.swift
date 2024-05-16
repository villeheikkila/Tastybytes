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
    @Binding var isLogoVisible: Bool

    var productItemViewExtras: Set<ProductItemView.Extra> {
        product.logos.isEmpty ? [.companyLink] : [.companyLink, .logoOnRight]
    }

    var body: some View {
        ProductItemView(product: product, extras: productItemViewExtras)
            .isVisible($isLogoVisible)
        ProductScreenActionSection(
            isOnWishlist: $isOnWishlist,
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

public extension View {
    func isVisible(_ isVisible: Binding<Bool>) -> some View {
        modifier(BecomingVisible(isVisible: isVisible))
    }
}

private struct BecomingVisible: ViewModifier {
    @Binding var isVisible: Bool

    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    updateVisibility(with: proxy)
                }
                .onChange(of: proxy.frame(in: .global)) {
                    updateVisibility(with: proxy)
                }
            }
        )
    }

    @MainActor
    private func updateVisibility(with proxy: GeometryProxy) {
        isVisible = UIScreen.main.bounds.intersects(proxy.frame(in: .global))
    }
}
