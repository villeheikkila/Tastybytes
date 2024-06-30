import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInImageCellView: View {
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    let checkInImage: ImageEntity.JoinedCheckIn

    var body: some View {
        HStack {
            RemoteImage(url: checkInImage.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                } else if let blurHash = checkInImage.blurHash {
                    BlurHashPlaceholder(blurHash: blurHash, height: 100)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(
                RoundedRectangle(cornerRadius: 4)
            )
            .onTapGesture {
                router.fetchAndNavigateTo(repository, .checkIn(id: checkInImage.checkIn.id))
            }
            .accessibilityAddTraits(.isButton)
        }
    }
}
