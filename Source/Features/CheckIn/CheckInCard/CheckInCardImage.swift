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
        if let imageUrl = checkIn.getImageUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
            RemoteImageBlurHash(url: imageUrl, blurHash: checkIn.images.first?.blurHash, height: 200) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: imageHeight)
                    .clipped()
                    .contentShape(Rectangle())
                    .openSheetOnTap(.checkInImage(checkIn: checkIn, imageUrl: imageUrl, onDeleteImage: onDeleteImage))
            }
            .frame(height: imageHeight)
            .padding(.vertical, 4)
        }
    }
}
