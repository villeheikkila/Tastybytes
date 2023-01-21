import CachedAsyncImage
import SwiftUI

struct AvatarView: View {
  let avatarUrl: URL?
  let size: CGFloat
  let id: UUID

  var body: some View {
    if let url = avatarUrl {
      CachedAsyncImage(url: url, urlCache: .imageCache) { image in
        image.resizable()
      } placeholder: {
        ProgressView()
      }
      .clipShape(Circle())
      .aspectRatio(contentMode: .fill)
      .frame(width: size, height: size)
    } else {
      Image(systemName: "person.fill")
        .resizable()
        .padding(.all, size / 5)
        .clipShape(Circle())
        .aspectRatio(contentMode: .fill)
        .frame(width: size, height: size)
        .foregroundColor(getConsistentColor(seed: id.uuidString))
    }
  }
}
