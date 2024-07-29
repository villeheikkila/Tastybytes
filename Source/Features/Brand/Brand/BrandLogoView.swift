import Components

import Models
import SwiftUI

struct BrandLogoView: View {
    let brand: BrandProtocol
    let size: Double

    var body: some View {
        Group {
            if let logo = brand.logos.first {
                ImageEntityView(image: logo, content: { image in
                    image.resizable()
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
