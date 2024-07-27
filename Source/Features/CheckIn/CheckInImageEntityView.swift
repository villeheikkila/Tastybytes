import Components

import Models
import SwiftUI

struct CheckInImageEntityView: View {
    @Environment(AppModel.self) private var appModel
    let imageEntity: ImageEntityUrl

    private let height = 300.0

    var body: some View {
        HStack {
            Spacer()
            if let imageUrl = imageEntity.getLogoUrl(baseUrl: appModel.infoPlist.supabaseUrl) {
                RemoteImageBlurHashView(url: imageUrl, blurHash: imageEntity.blurHash, height: height) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 8))
                        .frame(height: height)
                }
            }
            Spacer()
        }
    }
}
