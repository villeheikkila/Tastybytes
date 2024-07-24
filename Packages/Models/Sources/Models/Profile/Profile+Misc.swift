import Extensions
import Foundation
public import Tagged

public extension Profile {
    enum NameDisplay: String, CaseIterable, Codable, Equatable, Sendable {
        case username
        case fullName = "full_name"
    }

    struct UpdateRequest: Encodable, Sendable {
        public let id: Profile.Id
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

        public init(id: Profile.Id, showFullName: Bool) {
            nameDisplay = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
            self.id = id
        }

        public init(id: Profile.Id, isPrivate: Bool) {
            self.isPrivate = isPrivate
            self.id = id
        }

        public init(id: Profile.Id, isOnboarded: Bool) {
            self.isOnboarded = isOnboarded
            self.id = id
        }

        public init(id: Profile.Id, username: String?, firstName: String?, lastName: String?) {
            self.username = username
            self.firstName = firstName
            self.lastName = lastName
            self.id = id
        }

        init(
            id: Profile.Id,
            isPrivate: Bool,
            showFullName: Bool,
            isOnboarded: Bool
        ) {
            self.id = id
            self.isPrivate = isPrivate
            nameDisplay = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
            self.isOnboarded = isOnboarded
        }
    }
}

public extension Profile {
    struct SettingsUpdateRequest: Encodable, Sendable {
        public let id: Profile.Id
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
            id: Profile.Id,
            sendReactionNotifications: Bool? = nil,
            sendTaggedCheckInNotifications: Bool? = nil,
            sendFriendRequestNotifications: Bool? = nil,
            sendCommentNotifications: Bool? = nil
        ) {
            self.id = id
            self.sendReactionNotifications = sendReactionNotifications
            self.sendTaggedCheckInNotifications = sendTaggedCheckInNotifications
            self.sendFriendRequestNotifications = sendFriendRequestNotifications
            self.sendCommentNotifications = sendCommentNotifications
        }
    }
}

public struct CategoryStatistics: Identifiable, Codable, Sendable, CategoryProtocol {
    public let id: Category.Id
    public let name: String
    public let icon: String?
    public let count: Int

    public struct CategoryStatisticsParams: Codable, Sendable {
        public init(id: Profile.Id) {
            self.id = id
        }

        public let id: Profile.Id

        enum CodingKeys: String, CodingKey {
            case id = "p_user_id"
        }
    }

    public var category: Category.Saved {
        Category.Saved(id: id, name: name, icon: icon)
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
        public init(userId: Profile.Id, timePeriod: StatisticsTimePeriod) {
            self.userId = userId
            self.timePeriod = timePeriod.rawValue
        }

        public let userId: Profile.Id
        public let timePeriod: String

        enum CodingKeys: String, CodingKey {
            case userId = "p_user_id"
            case timePeriod = "p_time_period"
        }
    }
}

public struct SubcategoryStatistics: Identifiable, Codable, Sendable {
    public let id: Subcategory.Id
    public let name: String
    public let count: Int

    public struct SubcategoryStatisticsParams: Codable, Sendable {
        public init(userId: Profile.Id, categoryId: Category.Id) {
            self.userId = userId
            self.categoryId = categoryId
        }

        public let userId: Profile.Id
        public let categoryId: Category.Id

        enum CodingKeys: String, CodingKey {
            case userId = "p_user_id"
            case categoryId = "p_category_id"
        }
    }

    public var subcategory: Subcategory.Saved {
        Subcategory.Saved(id: id, name: name, isVerified: true)
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

public extension ProfileProtocol {
    func getAvatarUrl(baseUrl: URL) -> URL? {
        guard let imageEntity = avatars.first else { return nil }
        return imageEntity.getLogoUrl(baseUrl: baseUrl)
    }
}

public struct NumberOfCheckInsByDayRequest: Sendable, Encodable {
    public let profileId: Profile.Id

    public init(profileId: Profile.Id) {
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
