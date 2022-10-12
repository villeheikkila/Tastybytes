import SwiftUI
import CachedAsyncImage

struct MiniAvatar: View {
    let avatarUrl: String?

    var body: some View {
        if let avatarUrL = avatarUrl {
            CachedAsyncImage(url: getAvatarURL(avatarUrl: avatarUrL)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .frame(width: 24, height: 24)
        } else {
            Text("HEI")
        }
    }
}
