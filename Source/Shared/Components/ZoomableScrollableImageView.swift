import Components
import Models
import SwiftUI

public struct ZoomableRemoteImageView: View {
    @Environment(AppModel.self) private var appModel
    let imageEntity: ImageEntity.Saved

    public var body: some View {
        ZoomableScrollableView {
            if let imageUrl = imageEntity.getLogoUrl(baseUrl: appModel.infoPlist.supabaseUrl) {
                RemoteImageView(url: imageUrl, content: { image in
                    image
                        .resizable()
                        .clipShape(.rect(cornerRadius: 8))
                        .scaledToFit()
                        .padding(.horizontal, 8)
                }, progress: {
                    ProgressView()
                })
            }
        }
    }
}
