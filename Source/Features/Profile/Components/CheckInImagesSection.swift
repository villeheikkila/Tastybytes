import Models
import SwiftUI

struct CheckInImagesSection: View {
    let checkInImages: [ImageEntity.CheckInId]
    let isLoading: Bool
    let onLoadMore: () -> Void

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(checkInImages) { checkInImage in
                        CheckInImageCellView(checkInImage: checkInImage)
                            .onAppear {
                                if checkInImage == checkInImages.last, isLoading != true {
                                    onLoadMore()
                                }
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .contentMargins(.horizontal, 20.0, for: .scrollContent)
        .listRowInsets(.init())
    }
}
