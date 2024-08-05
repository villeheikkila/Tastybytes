import Components
import Models
import SwiftUI

public struct ZoomableRemoteImageView: View {
    let imageEntity: ImageEntity.Saved

    public var body: some View {
        ZoomableScrollableView {
            ImageEntityView(image: imageEntity, content: { image in
                image
                    .resizable()
                    .clipShape(.rect(cornerRadius: 8))
                    .scaledToFit()
                    .padding(.horizontal, 8)
            })
        }
    }
}
