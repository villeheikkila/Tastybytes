import CachedAsyncImage
import SwiftUI

struct AvatarView: View {
  let avatarUrl: URL?
  let size: Double
  let id: UUID

  var body: some View {
    if let avatarUrl {
      CachedAsyncImage(url: avatarUrl, urlCache: .imageCache) { image in
        image.resizable()
      } placeholder: {
        ProgressView()
      }
      .clipShape(Circle())
      .aspectRatio(contentMode: .fill)
      .frame(width: size, height: size)
      .accessibility(hidden: true)
    } else {
      Image(systemSymbol: .personFill)
        .resizable()
        .padding(.all, size / 5)
        .clipShape(Circle())
        .aspectRatio(contentMode: .fill)
        .frame(width: size, height: size)
        .foregroundColor(getConsistentColor(seed: id.uuidString))
        .accessibility(hidden: true)
    }
  }
}
