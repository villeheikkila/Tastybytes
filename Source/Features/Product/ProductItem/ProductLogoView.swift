import Components
import EnvironmentModels
import Models
import SwiftUI

struct ProductLogoView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let product: Product.Joined
    let size: Double

    var logoUrl: URL? {
        guard let logo = product.logos.first else { return nil }
        return logo.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)
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
