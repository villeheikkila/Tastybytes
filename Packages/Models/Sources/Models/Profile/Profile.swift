import Extensions
import Foundation

public protocol AvatarURL {
    var id: UUID { get }
    var avatarFile: String? { get }
}

public struct Profile: Identifiable, Codable, Hashable, Sendable, AvatarURL {
    public let id: UUID
    public let preferredName: String
    public let isPrivate: Bool
    public let avatarFile: String?
    public let joinedAt: Date

    public init(id: UUID, preferredName: String, isPrivate: Bool, avatarFile: String?, joinedAt: Date) {
        self.id = id
        self.preferredName = preferredName
        self.isPrivate = isPrivate
        self.avatarFile = avatarFile
        self.joinedAt = joinedAt
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case preferredName = "preferred_name"
        case isPrivate = "is_private"
        case avatarFile = "avatar_file"
        case joinedAt = "joined_at"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        let joinedAtRaw = try values.decode(String.self, forKey: .joinedAt)

        if let date = CustomDateFormatter.shared.parse(string: joinedAtRaw, .date) {
            joinedAt = date
        } else {
            joinedAt = Date()
        }
        preferredName = try values.decode(String.self, forKey: .preferredName)
        isPrivate = try values.decode(Bool.self, forKey: .isPrivate)
        avatarFile = try values.decodeIfPresent(String.self, forKey: .avatarFile)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        let joinedAtRaw = CustomDateFormatter.shared.format(date: joinedAt, .date)
        try container.encode(joinedAtRaw, forKey: .joinedAt)
        try container.encode(preferredName, forKey: .preferredName)
        try container.encode(isPrivate, forKey: .isPrivate)
        try container.encodeIfPresent(avatarFile, forKey: .avatarFile)
    }
}

public extension Profile {
    struct Extended: Identifiable, Codable, Sendable, AvatarURL {
        public let id: UUID
        public let username: String?
        public let firstName: String?
        public let lastName: String?
        public let joinedAt: Date
        public let isPrivate: Bool
        public let isOnboarded: Bool
        public let avatarFile: String?
        public let preferredName: String
        public let nameDisplay: NameDisplay
        public let roles: [Role]
        public let settings: ProfileSettings

        public init(
            id: UUID,
            username: String?,
            joinedAt: Date,
            isPrivate: Bool,
            isOnboarded: Bool,
            preferredName: String,
            nameDisplay: Profile.NameDisplay,
            roles: [Role],
            settings: ProfileSettings,
            firstName: String? = nil,
            lastName: String? = nil,
            avatarFile: String? = nil
        ) {
            self.id = id
            self.username = username
            self.firstName = firstName
            self.lastName = lastName
            self.joinedAt = joinedAt
            self.isPrivate = isPrivate
            self.isOnboarded = isOnboarded
            self.avatarFile = avatarFile
            self.preferredName = preferredName
            self.nameDisplay = nameDisplay
            self.roles = roles
            self.settings = settings
        }

        public func copyWith(
            username: String? = nil,
            firstName: String? = nil,
            lastName: String? = nil,
            joinedAt: Date? = nil,
            isPrivate: Bool? = nil,
            isOnboarded: Bool? = nil,
            avatarFile: String?? = nil,
            preferredName: String? = nil,
            nameDisplay: Profile.NameDisplay? = nil,
            roles: [Role]? = nil,
            settings: ProfileSettings? = nil
        ) -> Profile.Extended {
            Profile.Extended(
                id: id,
                username: username ?? self.username,
                joinedAt: joinedAt ?? self.joinedAt,
                isPrivate: isPrivate ?? self.isPrivate,
                isOnboarded: isOnboarded ?? self.isOnboarded,
                preferredName: preferredName ?? self.preferredName,
                nameDisplay: nameDisplay ?? self.nameDisplay,
                roles: roles ?? self.roles,
                settings: settings ?? self.settings,
                firstName: firstName ?? self.firstName,
                lastName: lastName ?? self.lastName,
                avatarFile: avatarFile ?? self.avatarFile
            )
        }

        public var profile: Profile {
            Profile(
                id: id,
                preferredName: preferredName,
                isPrivate: isPrivate,
                avatarFile: avatarFile,
                joinedAt: joinedAt
            )
        }

        enum CodingKeys: String, CodingKey, CaseIterable {
            case id
            case username
            case joinedAt = "joined_at"
            case preferredName = "preferred_name"
            case isPrivate = "is_private"
            case isOnboarded = "is_onboarded"
            case firstName = "first_name"
            case lastName = "last_name"
            case avatarFile = "avatar_file"
            case nameDisplay = "name_display"
            case notification = "notifications"
            case roles
            case settings = "profile_settings"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(UUID.self, forKey: .id)
            username = try values.decodeIfPresent(String.self, forKey: .username)
            let joinedAtRaw = try values.decode(String.self, forKey: .joinedAt)

            if let date = CustomDateFormatter.shared.parse(string: joinedAtRaw, .date) {
                joinedAt = date
            } else {
                joinedAt = Date()
            }
            preferredName = try values.decodeIfPresent(String.self, forKey: .preferredName) ?? ""
            isPrivate = try values.decode(Bool.self, forKey: .isPrivate)
            isOnboarded = try values.decode(Bool.self, forKey: .isOnboarded)
            firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
            lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
            avatarFile = try values.decodeIfPresent(String.self, forKey: .avatarFile)
            nameDisplay = try values.decode(NameDisplay.self, forKey: .nameDisplay)
            roles = try values.decode([Role].self, forKey: .roles)

            settings = try values.decode(ProfileSettings.self, forKey: .settings)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(username, forKey: .username)
            try container.encode(joinedAt, forKey: .joinedAt)
            try container.encode(preferredName, forKey: .preferredName)
            try container.encode(isPrivate, forKey: .isPrivate)
            try container.encode(isOnboarded, forKey: .isOnboarded)
            try container.encodeIfPresent(firstName, forKey: .firstName)
            try container.encodeIfPresent(lastName, forKey: .lastName)
            try container.encodeIfPresent(avatarFile, forKey: .avatarFile)
            try container.encode(nameDisplay, forKey: .nameDisplay)
            try container.encode(roles, forKey: .roles)
            try container.encode([settings], forKey: .settings)
        }
    }
}

public extension Profile {
    enum NameDisplay: String, CaseIterable, Codable, Equatable, Sendable {
        case username
        case fullName = "full_name"
    }

    struct UpdateRequest: Codable, Sendable {
        public var username: String?
        public var firstName: String?
        public var lastName: String?
        public var nameDisplay: String?
        public var isPrivate: Bool?
        public var isOnboarded: Bool?

        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case nameDisplay = "name_display"
            case isPrivate = "is_private"
            case isOnboarded = "is_onboarded"
        }

        public init(showFullName: Bool) {
            nameDisplay = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
        }

        public init(isPrivate: Bool) {
            self.isPrivate = isPrivate
        }

        public init(isOnboarded: Bool) {
            self.isOnboarded = isOnboarded
        }

        public init(username: String?, firstName: String?, lastName: String?) {
            self.username = username
            self.firstName = firstName
            self.lastName = lastName
        }

        init(
            isPrivate: Bool,
            showFullName: Bool,
            isOnboarded: Bool
        ) {
            self.isPrivate = isPrivate
            nameDisplay = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
            self.isOnboarded = isOnboarded
        }
    }
}

public struct ProfileSettings: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let sendReactionNotifications: Bool
    public let sendTaggedCheckInNotifications: Bool
    public let sendFriendRequestNotifications: Bool
    public let sendCommentNotifications: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case sendReactionNotifications = "send_reaction_notifications"
        case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
        case sendFriendRequestNotifications = "send_friend_request_notifications"
        case sendCommentNotifications = "send_comment_notifications"
    }
}

public extension ProfileSettings {
    struct UpdateRequest: Codable, Sendable {
        var sendReactionNotifications: Bool?
        var sendTaggedCheckInNotifications: Bool?
        var sendFriendRequestNotifications: Bool?
        var sendCommentNotifications: Bool?

        enum CodingKeys: String, CodingKey {
            case sendReactionNotifications = "send_reaction_notifications"
            case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
            case sendFriendRequestNotifications = "send_friend_request_notifications"
            case sendCommentNotifications = "send_comment_notifications"
        }

        public init(
            sendReactionNotifications: Bool? = nil,
            sendTaggedCheckInNotifications: Bool? = nil,
            sendFriendRequestNotifications: Bool? = nil,
            sendCommentNotifications: Bool? = nil
        ) {
            self.sendReactionNotifications = sendReactionNotifications
            self.sendTaggedCheckInNotifications = sendTaggedCheckInNotifications
            self.sendFriendRequestNotifications = sendFriendRequestNotifications
            self.sendCommentNotifications = sendCommentNotifications
        }
    }
}

public struct Contributions: Codable, Sendable {
    public let products: Int
    public let companies: Int
    public let brands: Int
    public let subBrands: Int
    public let barcodes: Int

    enum CodingKeys: String, CodingKey, CaseIterable {
        case products
        case companies
        case brands
        case subBrands = "sub_brands"
        case barcodes
    }

    public struct ContributionsParams: Codable, Sendable {
        public init(id: UUID) {
            self.id = id
        }

        let id: UUID

        enum CodingKeys: String, CodingKey {
            case id = "p_uid"
        }
    }
}

public struct CategoryStatistics: Identifiable, Codable, Sendable, CategoryProtocol {
    public let id: Int
    public let name: String
    public let icon: String?
    public let count: Int

    public struct CategoryStatisticsParams: Codable, Sendable {
        public init(id: UUID) {
            self.id = id
        }

        public let id: UUID

        enum CodingKeys: String, CodingKey {
            case id = "p_user_id"
        }
    }

    public var category: Category {
        Category(id: id, name: name, icon: icon)
    }
}

public struct TimePeriodStatistic: Codable, Sendable {
    public enum TimePeriod: String, CaseIterable, Sendable {
        case week, month, year, all

        public var label: String {
            rawValue.capitalized
        }
    }

    public let checkIns: Int
    public let newUniqueProducts: Int

    enum CodingKeys: String, CodingKey {
        case checkIns = "check_ins"
        case newUniqueProducts = "new_unique_products"
    }

    public struct RequestParams: Codable, Sendable {
        public init(userId: UUID, timePeriod: TimePeriod) {
            self.userId = userId
            self.timePeriod = timePeriod.rawValue
        }

        public let userId: UUID
        public let timePeriod: String

        enum CodingKeys: String, CodingKey {
            case userId = "p_user_id"
            case timePeriod = "p_time_period"
        }
    }
}

public struct SubcategoryStatistics: Identifiable, Codable, Sendable {
    public let id: Int
    public let name: String
    public let count: Int

    public struct SubcategoryStatisticsParams: Codable, Sendable {
        public init(userId: UUID, categoryId: Int) {
            self.userId = userId
            self.categoryId = categoryId
        }

        public let userId: UUID
        public let categoryId: Int

        enum CodingKeys: String, CodingKey {
            case userId = "p_user_id"
            case categoryId = "p_category_id"
        }
    }

    public var subcategory: Subcategory {
        Subcategory(id: id, name: name, isVerified: true)
    }
}

public extension Profile {
    struct UsernameCheckRequest: Codable, Sendable {
        public init(username: String) {
            self.username = username
        }

        public let username: String

        enum CodingKeys: String, CodingKey {
            case username = "p_username"
        }
    }

    struct PushNotificationToken: Identifiable, Codable, Hashable, Sendable {
        public var id: String { deviceToken }
        public let deviceToken: String

        public init(deviceToken: String) {
            self.deviceToken = deviceToken
        }

        enum CodingKeys: String, CodingKey {
            case deviceToken = "p_device_token"
        }
    }
}

public extension AvatarURL {
    var avatarUrl: URL? {
        guard let avatarFile else { return nil }
        return URL(bucket: .avatars, fileName: "\(id.uuidString.lowercased())/\(avatarFile)")
    }
}
