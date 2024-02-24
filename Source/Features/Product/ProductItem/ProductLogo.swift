import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct ProductLogo: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let product: Product.Joined
    let size: Double

    var body: some View {
        Group {
            if let logoUrl = product.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                RemoteImage(url: logoUrl) { state in
                    if let image = state.image {
                        image.resizable()
                    } else {
                        ProgressView()
                    }
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
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
