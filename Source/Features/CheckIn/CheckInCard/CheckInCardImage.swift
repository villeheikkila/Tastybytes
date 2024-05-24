import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct CheckInCardImage: View {
    @Environment(Router.self) private var router
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var showFullPicture = false
    @State private var blurHashPlaceHolder: UIImage?

    let checkIn: CheckIn
    let onDeleteImage: CheckInImageSheet.OnDeleteImageCallback?

    private let imageHeight: Double = 200

    var body: some View {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(checkIn.images) { image in
                        if let imageUrl = image.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                            RemoteImageBlurHash(url: imageUrl, blurHash: image.blurHash, height: 200) { image in
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
            .openSheetOnTap(.checkInImage(checkIn: checkIn, onDeleteImage: onDeleteImage))
        }
    }
}
