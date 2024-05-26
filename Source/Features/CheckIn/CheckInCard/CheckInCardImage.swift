import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct CheckInCardImage: View {
    let checkIn: CheckIn
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?

    var body: some View {
        CheckInImageScrollView(checkIn: checkIn)
            .openSheetOnTap(.checkInImage(checkIn: checkIn, onDeleteImage: onDeleteImage))
    }
}

@MainActor
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
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .frame(height: imageHeight)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                        .containerRelativeFrame(.horizontal)
                    }
                }
            }
            .scrollTargetBehavior(.paging)
        }
    }
}

