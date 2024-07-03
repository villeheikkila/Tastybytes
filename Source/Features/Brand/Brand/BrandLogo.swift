import Components
import EnvironmentModels
import Models
import SwiftUI

struct BrandLogo: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    let brand: BrandProtocol
    let size: Double

    var body: some View {
        Group {
            if let logoUrl = brand.getLogoUrl(baseUrl: appEnvironmentModel.infoPlist.supabaseUrl) {
                RemoteImage(url: logoUrl, content: { image in
                    image.resizable()
                }, progress: {
                    ProgressView()
                })
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
