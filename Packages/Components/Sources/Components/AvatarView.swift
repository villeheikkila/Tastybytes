import Models
import SwiftUI

@MainActor
public struct AvatarView: View {
    @Environment(\.avatarSize) private var avatarSize
    let avatarUrl: URL?
    let id: UUID

    public init(avatarUrl: URL? = nil, id: UUID) {
        self.avatarUrl = avatarUrl
        self.id = id
    }

    public init(profile: Profile, baseUrl: URL) {
        avatarUrl = profile.getAvatarUrl(baseUrl: baseUrl)
        id = profile.id
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
            .frame(width: avatarSize.size, height: avatarSize.size)
            .accessibility(hidden: true)
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .padding(.all, avatarSize.size / 5)
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .frame(width: avatarSize.size, height: avatarSize.size)
                .foregroundColor(Color(seed: id.uuidString))
                .accessibility(hidden: true)
        }
    }
}

public enum AvatarSize {
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

public struct AvatarSizeKey: EnvironmentKey {
    public static var defaultValue: AvatarSize = .small
}

public extension EnvironmentValues {
    var avatarSize: AvatarSize {
        get { self[AvatarSizeKey.self] }
        set { self[AvatarSizeKey.self] = newValue }
    }
}

public extension View {
    func avatarSize(_ size: AvatarSize) -> some View {
        environment(\.avatarSize, size)
    }
}
