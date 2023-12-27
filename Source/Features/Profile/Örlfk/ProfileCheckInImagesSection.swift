import Models
import SwiftUI

struct ProfileCheckInImagesSection: View {
    let checkInImages: [CheckIn.Image]
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
        }
    }
}
