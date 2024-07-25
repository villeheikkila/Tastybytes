public import Tagged
import Foundation

public extension Profile {
    struct Extended: Identifiable, Codable, Sendable, Hashable, AvatarURL, ProfileProtocol {
        public let id: Profile.Id
        public let username: String?
        public let firstName: String?
        public let lastName: String?
        public let joinedAt: Date
        public let isPrivate: Bool
        public let isOnboarded: Bool
        private let rawPreferredName: String?
        public let nameDisplay: NameDisplay
        public let roles: [Role.Joined]
        public let settings: Profile.Settings
        public let avatars: [ImageEntity.Saved]

        public var preferredName: String {
            rawPreferredName ?? ""
        }

        public init(
            id: Profile.Id,
            username: String?,
            joinedAt: Date,
            isPrivate: Bool,
            isOnboarded: Bool,
            preferredName: String?,
            nameDisplay: Profile.NameDisplay,
            roles: [Role.Joined],
            settings: Profile.Settings,
            avatars: [ImageEntity.Saved],
            firstName: String? = nil,
            lastName: String? = nil
        ) {
            self.id = id
            self.username = username
            self.firstName = firstName
            self.lastName = lastName
            self.joinedAt = joinedAt
            self.isPrivate = isPrivate
            self.isOnboarded = isOnboarded
            rawPreferredName = preferredName
            self.nameDisplay = nameDisplay
            self.roles = roles
            self.settings = settings
            self.avatars = avatars
        }

        public func copyWith(
            username: String? = nil,
            firstName: String? = nil,
            lastName: String? = nil,
            joinedAt: Date? = nil,
            isPrivate: Bool? = nil,
            isOnboarded: Bool? = nil,
            preferredName: String? = nil,
            nameDisplay: Profile.NameDisplay? = nil,
            roles: [Role.Joined]? = nil,
            settings: Profile.Settings? = nil,
            avatars: [ImageEntity.Saved]? = nil
        ) -> Self {
            .init(
                id: id,
                username: username ?? self.username,
                joinedAt: joinedAt ?? self.joinedAt,
                isPrivate: isPrivate ?? self.isPrivate,
                isOnboarded: isOnboarded ?? self.isOnboarded,
                preferredName: preferredName ?? self.preferredName,
                nameDisplay: nameDisplay ?? self.nameDisplay,
                roles: roles ?? self.roles,
                settings: settings ?? self.settings,
                avatars: avatars ?? self.avatars,
                firstName: firstName ?? self.firstName,
                lastName: lastName ?? self.lastName
            )
        }

        public var profile: Profile.Saved {
            .init(
                id: id,
                preferredName: preferredName,
                isPrivate: isPrivate,
                joinedAt: joinedAt,
                avatars: avatars
            )
        }

        public func hasRole(_ role: Role.Name) -> Bool {
            roles.contains(where: { $0.name == role.rawValue })
        }

        enum CodingKeys: String, CodingKey, CaseIterable {
            case id
            case username
            case joinedAt = "joined_at"
            case rawPreferredName = "preferred_name"
            case isPrivate = "is_private"
            case isOnboarded = "is_onboarded"
            case firstName = "first_name"
            case lastName = "last_name"
            case nameDisplay = "name_display"
            case roles
            case settings = "profile_settings"
            case avatars = "profile_avatars"
        }
    }
}
