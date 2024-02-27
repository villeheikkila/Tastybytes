import Models
import SwiftUI

@MainActor
struct CheckInImagesSection: View {
    let checkInImages: [ImageEntity.JoinedCheckIn]
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
    }
}
