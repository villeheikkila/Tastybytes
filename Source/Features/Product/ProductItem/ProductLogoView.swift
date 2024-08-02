import Components
import Models
import SwiftUI

extension EnvironmentValues {
    @Entry var productLogoShowPlacerholder: Bool = false
}

extension View {
    func productLogoShowPlacerholder(_ enabled: Bool) -> some View {
        environment(\.productLogoShowPlacerholder, enabled)
    }
}

struct ProductLogoView: View {
    @Environment(\.productLogoShowPlacerholder) private var productLogoShowPlacerholder

    let product: Product.Joined
    let size: Double

    var body: some View {
        Group {
            if let image = product.effectiveLogo {
                ImageEntityView(image: image) { image in
                    image
                        .renderingMode(.original)
                        .resizable()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .accessibility(hidden: true)
            } else if productLogoShowPlacerholder {
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
