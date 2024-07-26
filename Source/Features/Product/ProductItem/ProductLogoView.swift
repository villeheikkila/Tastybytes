import Components

import Models
import SwiftUI

struct ProductLogoView: View {
    @Environment(AppModel.self) private var appModel
    let product: ProductLogoProtocol
    let size: Double

    var logoUrl: URL? {
        guard let logo = product.logos.first else { return nil }
        return logo.getLogoUrl(baseUrl: appModel.infoPlist.supabaseUrl)
    }

    var body: some View {
        Group {
            if let logoUrl {
                RemoteImageView(url: logoUrl) { image in
                    image.resizable()
                } progress: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .accessibility(hidden: true)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .padding(.all, size / 5)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .foregroundColor(.primary)
                    .accessibility(hidden: true)
            }
        }
        .clipShape(.rect(cornerRadius: 8))
    }
}
