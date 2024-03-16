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

    var body: some View {
        if let imageUrl = checkIn.getImageUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
            RemoteImage(url: imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .contentShape(Rectangle())
                        .openSheetOnTap(.checkInImage(checkIn: checkIn, imageUrl: imageUrl))
                } else {
                    BlurHashPlaceholder(blurHash: checkIn.images.first?.blurHash, height: 200)
                }
            }
            .frame(height: 200)
            .padding(.vertical, 4)
        }
    }
}
