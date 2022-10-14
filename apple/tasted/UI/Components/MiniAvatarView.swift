import CachedAsyncImage
import SwiftUI

struct Avatar: View {
    let avatarUrl: String?
    let size: CGFloat
    let id: UUID

    var body: some View {
        if let avatarUrL = avatarUrl {
            CachedAsyncImage(url: getAvatarURL(avatarUrl: avatarUrL)) { image in
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


