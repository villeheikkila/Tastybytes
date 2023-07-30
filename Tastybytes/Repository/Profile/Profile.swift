import Foundation

protocol AvatarURL {
    var id: UUID { get }
    var avatarFile: String? { get }
}

extension AvatarURL {
    var avatarUrl: URL? {
        guard let avatarFile else { return nil }
        return URL(bucketId: Profile.getQuery(.avatarBucket), fileName: "\(id.uuidString.lowercased())/\(avatarFile)")
    }
}

struct Profile: Identifiable, Codable, Hashable, Sendable, AvatarURL {
    let id: UUID
    let preferredName: String
    let isPrivate: Bool
    let avatarFile: String?
    let joinedAt: Date

    init(id: UUID, preferredName: String, isPrivate: Bool, avatarFile: String?, joinedAt: Date) {
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

    init(from decoder: Decoder) throws {
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
}

extension Profile {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "profiles"
        let minimal = "id, is_private, preferred_name, avatar_file, joined_at"
        let saved =
            "id, first_name, last_name, username, avatar_file, name_display, preferred_name, is_private, is_onboarded, joined_at"
        let avatarBucketId = "avatars"

        switch queryType {
        case .tableName:
            return tableName
        case .avatarBucket:
            return avatarBucketId
        case let .minimal(withTableName):
            return queryWithTableName(tableName, minimal, withTableName)
        case let .extended(withTableName):
            return queryWithTableName(
                tableName,
                [saved, ProfileSettings.getQuery(.saved(true)), Role.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case avatarBucket
        case minimal(_ withTableName: Bool)
        case extended(_ withTableName: Bool)
    }
}

extension Profile {
    struct Extended: Identifiable, Codable, Sendable, AvatarURL {
        let id: UUID
        let username: String?
        let firstName: String?
        let lastName: String?
        let joinedAt: Date
        let isPrivate: Bool
        let isOnboarded: Bool
        let avatarFile: String?
        let preferredName: String
        let nameDisplay: NameDisplay
        let roles: [Role]
        let settings: ProfileSettings

        init(
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

        func copyWith(
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

        var profile: Profile {
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

        init(from decoder: Decoder) throws {
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

        func encode(to encoder: Encoder) throws {
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

extension Profile {
    enum NameDisplay: String, CaseIterable, Codable, Equatable, Sendable {
        case username
        case fullName = "full_name"
    }

    struct UpdateRequest: Codable, Sendable {
        var username: String?
        var firstName: String?
        var lastName: String?
        var nameDisplay: String?
        var isPrivate: Bool?
        var isOnboarded: Bool?

        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case nameDisplay = "name_display"
            case isPrivate = "is_private"
            case isOnboarded = "is_onboarded"
        }

        init(showFullName: Bool) {
            nameDisplay = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
        }

        init(isPrivate: Bool) {
            self.isPrivate = isPrivate
        }

        init(isOnboarded: Bool) {
            self.isOnboarded = isOnboarded
        }

        init(username: String?, firstName: String?, lastName: String?) {
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

struct ProfileSettings: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let sendReactionNotifications: Bool
    let sendTaggedCheckInNotifications: Bool
    let sendFriendRequestNotifications: Bool
    let sendCommentNotifications: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case sendReactionNotifications = "send_reaction_notifications"
        case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
        case sendFriendRequestNotifications = "send_friend_request_notifications"
        case sendCommentNotifications = "send_comment_notifications"
    }
}

extension ProfileSettings {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "profile_settings"
        let saved =
            """
            id, send_reaction_notifications, send_tagged_check_in_notifications,\
            send_friend_request_notifications, send_comment_notifications
            """

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}

extension ProfileSettings {
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

        init(
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

struct Contributions: Codable, Sendable {
    let products: Int
    let companies: Int
    let brands: Int
    let subBrands: Int
    let barcodes: Int

    enum CodingKeys: String, CodingKey, CaseIterable {
        case products
        case companies
        case brands
        case subBrands = "sub_brands"
        case barcodes
    }

    struct ContributionsParams: Codable, Sendable {
        let id: UUID

        enum CodingKeys: String, CodingKey {
            case id = "p_uid"
        }
    }

    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            return "products, companies, brands, sub_brands, barcodes"
        }
    }
}

struct CategoryStatistics: Identifiable, Codable, Sendable, CategoryProtocol {
    let id: Int
    let name: String
    let icon: String
    let count: Int

    struct CategoryStatisticsParams: Codable, Sendable {
        let id: UUID

        enum CodingKeys: String, CodingKey {
            case id = "p_user_id"
        }
    }

    var category: Category {
        Category(id: id, name: name, icon: icon)
    }

    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            return "id, name, icon, count"
        }
    }
}

struct SubcategoryStatistics: Identifiable, Codable, Sendable {
    let id: Int
    let name: String
    let count: Int

    struct SubcategoryStatisticsParams: Codable, Sendable {
        let userId: UUID
        let categoryId: Int

        enum CodingKeys: String, CodingKey {
            case userId = "p_user_id"
            case categoryId = "p_category_id"
        }
    }

    var subcategory: Subcategory {
        Subcategory(id: id, name: name, isVerified: true)
    }

    enum QueryPart {
        case value
    }

    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            return "id, name, count"
        }
    }
}

extension Profile {
    struct UsernameCheckRequest: Codable, Sendable {
        let username: String

        enum CodingKeys: String, CodingKey {
            case username = "p_username"
        }
    }

    struct PushNotificationToken: Identifiable, Codable, Hashable, Sendable {
        var id: String { firebaseRegistrationToken }
        let firebaseRegistrationToken: String

        init(firebaseRegistrationToken: String) {
            self.firebaseRegistrationToken = firebaseRegistrationToken
        }

        enum CodingKeys: String, CodingKey {
            case firebaseRegistrationToken = "p_push_notification_token"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(firebaseRegistrationToken, forKey: .firebaseRegistrationToken)
        }
    }
}
