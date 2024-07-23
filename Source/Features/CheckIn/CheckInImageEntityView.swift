import Components
import EnvironmentModels
import Models
import SwiftUI

struct CheckInImageEntityView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let imageEntity: ImageEntityUrl

    private let height = 300.0

    var body: some View {
        HStack {
            Spacer()
            if let imageUrl = imageEntity.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                RemoteImageBlurHashView(url: imageUrl, blurHash: imageEntity.blurHash, height: height) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: height)
                }
            }
            Spacer()
        }
    }
}
