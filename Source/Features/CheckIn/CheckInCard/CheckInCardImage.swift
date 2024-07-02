import Components
import EnvironmentModels
import Models
import SwiftUI

struct CheckInCardImage: View {
    let checkIn: CheckIn
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?

    var body: some View {
        CheckInImageScrollView(checkIn: checkIn)
            .openOnTap(.sheet(.checkInImage(checkIn: checkIn, onDeleteImage: onDeleteImage)))
    }
}

struct CheckInImageScrollView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let checkIn: CheckIn

    private let imageHeight: Double = 200

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(checkIn.images) { image in
                    if let imageUrl = image.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                        RemoteImageBlurHash(url: imageUrl, blurHash: image.blurHash, height: imageHeight) { image in
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
