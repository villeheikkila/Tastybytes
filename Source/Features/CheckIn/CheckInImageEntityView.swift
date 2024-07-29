import Components

import Models
import SwiftUI

struct CheckInImageEntityView: View {
    let imageEntity: ImageEntityProtocol

    private let height = 300.0

    var body: some View {
        HStack {
            Spacer()
            ImageEntityView(image: imageEntity) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 8))
                    .frame(height: height)
            }
            Spacer()
        }
    }
}
