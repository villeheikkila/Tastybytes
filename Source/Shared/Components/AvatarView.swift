import Components
import Models
import SwiftUI

public struct AvatarView: View {
    @Environment(\.avatarSize) private var avatarSize
    let image: ImageEntity.Saved?
    let id: Profile.Id

    public init(profile: ProfileProtocol) {
        image = profile.avatars.first
        id = profile.id
    }

    public var body: some View {
        if let image {
            ImageEntityView(image: image, content: { image in
                image.resizable()
            })
            .clipShape(.circle)
            .aspectRatio(contentMode: .fill)
            .frame(width: avatarSize.size, height: avatarSize.size)
            .accessibility(hidden: true)
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .padding(.all, avatarSize.size / 5)
                .clipShape(.circle)
                .aspectRatio(contentMode: .fill)
                .frame(width: avatarSize.size, height: avatarSize.size)
                .foregroundColor(Color(seed: id.uuidString))
                .accessibility(hidden: true)
        }
    }
}

public enum AvatarSize: Sendable {
    case small
    case medium
    case large
    case extraLarge
    case custom(Double)

    var size: Double {
        switch self {
        case .small:
            16
        case .medium:
            24
        case .large:
            32
        case .extraLarge:
            48
        case let .custom(size):
            size
        }
    }
}

public extension EnvironmentValues {
    @Entry var avatarSize: AvatarSize = .small
}

public extension View {
    func avatarSize(_ size: AvatarSize) -> some View {
        environment(\.avatarSize, size)
    }
}
