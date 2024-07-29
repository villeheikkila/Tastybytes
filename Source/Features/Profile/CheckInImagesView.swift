import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInImageCellView: View {
    let checkInImage: ImageEntity.JoinedCheckIn

    var body: some View {
        HStack {
            RouterLink(open: .screen(.checkIn(checkInImage.checkIn.id))) {
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
