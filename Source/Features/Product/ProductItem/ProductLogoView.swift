import Components

import Models
import SwiftUI

struct ProductLogoView: View {
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
