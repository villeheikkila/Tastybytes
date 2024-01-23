import Models
import SwiftUI

public struct AvatarView: View {
    let avatarUrl: URL?
    let size: Double
    let id: UUID
    
    public init(avatarUrl: URL? = nil, size: Double, id: UUID) {
        self.avatarUrl = avatarUrl
        self.size = size
        self.id = id
    }

    public init(profile: Profile, baseUrl: URL, size: Double = 24) {
        avatarUrl = profile.getAvatarUrl(baseUrl: baseUrl)
        id = profile.id
        self.size = size
    }

    public var body: some View {
        if let avatarUrl {
            RemoteImage(url: avatarUrl) { state in
                if let image = state.image {
                    image.resizable()
                } else {
                    ProgressView()
                }
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .accessibility(hidden: true)
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .padding(.all, size / 5)
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .foregroundColor(Color(seed: id.uuidString))
                .accessibility(hidden: true)
        }
    }
}
