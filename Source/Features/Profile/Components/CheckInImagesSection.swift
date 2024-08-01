import Models
import SwiftUI

struct CheckInImagesSection: View {
    let checkInImages: [ImageEntity.CheckInId]
    @Binding var page: Int
    let onLoadMore: () async -> Void

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(checkInImages) { checkInImage in
                        CheckInImageCellView(checkInImage: checkInImage)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .animation(.default, value: checkInImages)
            .onScrollTargetVisibilityChange(idType: ImageEntity.Id.self) { imageIds in
                if let lastImage = checkInImages.last, imageIds.contains(where: { $0 == lastImage.id }) {
                    page += 1
                }
            }
            .task(id: page) {
                await onLoadMore()
            }
        }
        .contentMargins(.horizontal, 20.0, for: .scrollContent)
        .listRowInsets(.init())
    }
}
