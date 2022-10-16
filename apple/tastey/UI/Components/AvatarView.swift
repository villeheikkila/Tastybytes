import CachedAsyncImage
import SwiftUI

struct AvatarView: View {
    let avatarUrl: URL?
    let size: CGFloat
    let id: UUID

    var body: some View {
        if let url = avatarUrl {
            CachedAsyncImage(url: url) { image in
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


