import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct CheckInImageCellView: View {
    let checkInImage: ImageEntity.CheckInId

    var body: some View {
        HStack {
            RouterLink(open: .screen(.checkIn(checkInImage.checkInId))) {
                ImageEntityView(image: checkInImage, content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                })
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 4))
            }
            .buttonStyle(.plain)
        }
    }
}
