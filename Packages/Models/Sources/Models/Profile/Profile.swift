import CoreLocation
import Extensions
import Foundation

public protocol AvatarURL {
    var id: UUID { get }
    var avatars: [ImageEntity] { get }
}

public struct Profile: Identifiable, Codable, Hashable, Sendable, AvatarURL {
    public let id: UUID
    private let rawPreferredName: String?
    public var preferredName: String {
        rawPreferredName ?? ""
    }

    public let isPrivate: Bool
    public let joinedAt: Date
    public let avatars: [ImageEntity]

    public init(id: UUID, preferredName: String?, isPrivate: Bool, joinedAt: Date, avatars: [ImageEntity]) {
        self.id = id
        rawPreferredName = preferredName
        self.isPrivate = isPrivate
        self.joinedAt = joinedAt
        self.avatars = avatars
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case rawPreferredName = "preferred_name"
        case isPrivate = "is_private"
        case joinedAt = "joined_at"
        case avatars = "profile_avatars"
    }

    public func copyWith(preferredName: String? = nil, isPrivate: Bool? = nil, joinedAt: Date? = nil, avatars: [ImageEntity]? = nil) -> Self {
        .init(
            id: id,
            preferredName: preferredName ?? self.preferredName,
            isPrivate: isPrivate ?? self.isPrivate,
            joinedAt: joinedAt ?? self.joinedAt,
            avatars: avatars ?? self.avatars
        )
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
        private let rawPreferredName: String?
        public var preferredName: String {
            rawPreferredName ?? ""
        }

        public let nameDisplay: NameDisplay
        public let roles: [Role]
        public let settings: ProfileSettings
        public let avatars: [ImageEntity]

        public init(
            id: UUID,
            username: String?,
            joinedAt: Date,
            isPrivate: Bool,
            isOnboarded: Bool,
            preferredName: String?,
            nameDisplay: Profile.NameDisplay,
            roles: [Role],
            settings: ProfileSettings,
            avatars: [ImageEntity],
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
            roles: [Role]? = nil,
            settings: ProfileSettings? = nil,
            avatars: [ImageEntity]? = nil
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

        public var profile: Profile {
            Profile(
                id: id,
                preferredName: preferredName,
                isPrivate: isPrivate,
                joinedAt: joinedAt,
                avatars: avatars
            )
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
    }

    public let checkIns: Int
    public let newUniqueProducts: Int

    enum CodingKeys: String, CodingKey {
        case checkIns = "check_ins"
        case newUniqueProducts = "new_unique_products"
    }

    public struct RequestParams: Codable, Sendable {
        public init(userId: UUID, timePeriod: StatisticsTimePeriod) {
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
    func getAvatarUrl(baseUrl: URL) -> URL? {
        guard let imageEntity = avatars.first else { return nil }
        return imageEntity.getLogoUrl(baseUrl: baseUrl)
    }
}

public struct NumberOfCheckInsByDayRequest: Sendable, Encodable {
    public let profileId: UUID

    public init(profileId: UUID) {
        self.profileId = profileId
    }

    enum CodingKeys: String, CodingKey {
        case profileId = "p_profile_id"
    }
}

public enum StatisticsTimePeriod: String, CaseIterable, Sendable {
    case week, month, sixMonths = "six_months", year
}

public struct CheckInsPerDay: Sendable, Codable, Identifiable {
    public var id: Double { checkInDate.timeIntervalSince1970 }
    public let checkInDate: Date
    public let numberOfCheckIns: Int
    public let uniqueProductCount: Int

    enum CodingKeys: String, CodingKey {
        case checkInDate = "check_in_date"
        case numberOfCheckIns = "number_of_check_ins"
        case uniqueProductCount = "unique_product_count"
    }
}

public struct ProfileTopLocations: Sendable, Decodable, Identifiable {
    public let id: UUID
    public let name: String
    public let title: String?
    public let location: CLLocation?
    public let countryCode: String?
    public let count: Int

    enum CodingKeys: String, CodingKey {
        case count = "check_ins_count"
        case id
        case name
        case title
        case countryCode = "country_code"
        case source
        case longitude
        case latitude
    }

    public var loc: Location {
        .init(id: id, mapKitIdentifier: nil, name: name, title: title, location: location, countryCode: countryCode, country: nil, source: "")
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        location = CLLocation(latitude: latitude, longitude: longitude)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        count = try container.decode(Int.self, forKey: .count)
    }
}

public extension Profile {
    struct Contributions: Codable, Sendable {
        public let products: [Product.Joined]
        public let companies: [Company]
        public let brands: [Brand]
        public let subBrands: [SubBrand.JoinedBrand]
        public let barcodes: [ProductBarcode.Joined]

        enum CodingKeys: String, CodingKey {
            case products
            case companies
            case brands
            case subBrands = "sub_brands"
            case barcodes
        }
    }
}
