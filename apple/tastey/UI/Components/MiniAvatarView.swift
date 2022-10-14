import CachedAsyncImage
import SwiftUI

struct Avatar: View {
    let avatarUrl: URL?
    let size: CGFloat
    let id: UUID

    var body: some View {
        if let avatarUrL = avatarUrl {
            CachedAsyncImage(url: avatarUrl) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
        } else {
            Image(systemName: "person.fill")
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .foregroundColor(getConsistentColor(seed: id.uuidString))
        }
    }
}


