import Foundation
public import Tagged

public extension Profile {
    struct Saved: Identifiable, Codable, Hashable, Sendable, AvatarURL, ProfileProtocol {
        public let id: Profile.Id
        private let rawPreferredName: String?
        public let isPrivate: Bool
        public let joinedAt: Date
        public let avatars: [ImageEntity.Saved]

        public var preferredName: String {
            rawPreferredName ?? ""
        }

        public init(id: Profile.Id, preferredName: String?, isPrivate: Bool, joinedAt: Date, avatars: [ImageEntity.Saved]) {
            self.id = id
            rawPreferredName = preferredName
            self.isPrivate = isPrivate
            self.joinedAt = joinedAt
            self.avatars = avatars
        }

        public init(profile: Profile.Detailed) {
            id = profile.id
            rawPreferredName = profile.preferredName
            isPrivate = profile.isPrivate
            joinedAt = profile.joinedAt
            avatars = profile.avatars
        }

        public init() {
            id = .init(rawValue: UUID())
            rawPreferredName = nil
            isPrivate = false
            joinedAt = Date.now
            avatars = []
        }

        enum CodingKeys: String, CodingKey, CaseIterable {
            case id
            case rawPreferredName = "preferred_name"
            case isPrivate = "is_private"
            case joinedAt = "joined_at"
            case avatars = "profile_avatars"
        }

        public func copyWith(preferredName: String? = nil, isPrivate: Bool? = nil, joinedAt: Date? = nil, avatars: [ImageEntity.Saved]? = nil) -> Self {
            .init(
                id: id,
                preferredName: preferredName ?? self.preferredName,
                isPrivate: isPrivate ?? self.isPrivate,
                joinedAt: joinedAt ?? self.joinedAt,
                avatars: avatars ?? self.avatars
            )
        }
    }
}
