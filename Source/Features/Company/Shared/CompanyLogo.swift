import Components
import Models
import SwiftUI

struct CompanyLogo: View {
    let company: CompanyLogoProtocol
    let size: Double

    public var body: some View {
        Group {
            if let image = company.logos.first {
                ImageEntityView(image: image, content: { image in
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
