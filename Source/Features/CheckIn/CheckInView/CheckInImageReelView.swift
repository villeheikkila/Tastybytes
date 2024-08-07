import Components
import Models
import Repositories
import SwiftUI

struct CheckInImageReelView: View {
    let checkIn: CheckIn.Joined
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?

    private let imageHeight: Double = 200

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(checkIn.images) { image in
                    RouterLink(open: .sheet(.checkInImage(checkIn: checkIn, onDeleteImage: onDeleteImage))) {
                        ImageEntityView(image: image) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: imageHeight)
                        }
                        .frame(height: imageHeight)
                        .clipShape(.rect(cornerRadius: 8))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                        .containerRelativeFrame(.horizontal)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
    }
}
