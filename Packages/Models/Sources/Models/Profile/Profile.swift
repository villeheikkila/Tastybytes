import CoreLocation
import Extensions
import Foundation
import Tagged

public protocol AvatarURL {
    var id: Profile.Id { get }
    var avatars: [ImageEntity] { get }
}

public protocol ProfileProtocol {
    var id: Profile.Id { get }
    var preferredName: String { get }
    var isPrivate: Bool { get }
    var joinedAt: Date { get }
    var avatars: [ImageEntity] { get }
}

public struct Profile: Identifiable, Codable, Hashable, Sendable, AvatarURL, ProfileProtocol {
    public let id: Profile.Id
    private let rawPreferredName: String?
    public var preferredName: String {
        rawPreferredName ?? ""
    }

    public let isPrivate: Bool
    public let joinedAt: Date
    public let avatars: [ImageEntity]

    public init(id: Profile.Id, preferredName: String?, isPrivate: Bool, joinedAt: Date, avatars: [ImageEntity]) {
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
    typealias Id = Tagged<Profile, UUID>
}

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
        public var preferredName: String {
            rawPreferredName ?? ""
        }

        public let nameDisplay: NameDisplay
        public let roles: [Role]
        public let settings: Profile.Settings
        public let avatars: [ImageEntity]

        public init(
            id: Profile.Id,
            username: String?,
            joinedAt: Date,
            isPrivate: Bool,
            isOnboarded: Bool,
            preferredName: String?,
            nameDisplay: Profile.NameDisplay,
            roles: [Role],
            settings: Profile.Settings,
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
            settings: Profile.Settings? = nil,
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

        public func hasRole(_ role: RoleName) -> Bool {
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

public extension Profile {
    struct Detailed: Identifiable, Decodable, Sendable, Hashable, AvatarURL, WithReports, ProfileProtocol {
        public let id: Profile.Id
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
        public let avatars: [ImageEntity]
        public let reports: [Report]

        public init(
            id: Profile.Id,
            username: String?,
            joinedAt: Date,
            isPrivate: Bool,
            isOnboarded: Bool,
            preferredName: String?,
            nameDisplay: Profile.NameDisplay,
            roles: [Role],
            avatars: [ImageEntity],
            firstName: String? = nil,
            lastName: String? = nil,
            reports: [Report]
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
            self.avatars = avatars
            self.reports = reports
        }

        public init() {
            id = .init(rawValue: UUID())
            username = nil
            firstName = nil
            lastName = nil
            joinedAt = Date.now
            isPrivate = false
            isOnboarded = false
            rawPreferredName = nil
            nameDisplay = .username
            roles = []
            avatars = []
            reports = []
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
            avatars: [ImageEntity]? = nil,
            reports: [Report]? = nil
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
                avatars: avatars ?? self.avatars,
                firstName: firstName ?? self.firstName,
                lastName: lastName ?? self.lastName,
                reports: reports ?? self.reports
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
            case avatars = "profile_avatars"
            case reports
        }
    }
}

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
    struct Settings: Identifiable, Codable, Hashable, Sendable {
        public let id: Profile.Id
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

public extension Profile {
    struct TopLocations: Sendable, Decodable, Identifiable {
        public let id: Location.Id
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
            id = try container.decode(Location.Id.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            title = try container.decodeIfPresent(String.self, forKey: .title)
            let longitude = try container.decode(Double.self, forKey: .longitude)
            let latitude = try container.decode(Double.self, forKey: .latitude)
            location = CLLocation(latitude: latitude, longitude: longitude)
            countryCode = try container.decode(String.self, forKey: .countryCode)
            count = try container.decode(Int.self, forKey: .count)
        }
    }
}

public extension Profile {
    struct Contributions: Decodable, Sendable {
        public let products: [Product.Joined]
        public let companies: [Company]
        public let brands: [Brand]
        public let subBrands: [SubBrand.JoinedBrand]
        public let barcodes: [Product.Barcode.Joined]
        public let reports: [Report]
        public let editSuggestions: [EditSuggestion]

        enum CodingKeys: String, CodingKey {
            case products
            case companies
            case brands
            case subBrands = "sub_brands"
            case barcodes
            case reports
            case productEditSuggestions = "product_edit_suggestions"
            case companyEditSuggestions = "company_edit_suggestions"
            case brandEditSuggestions = "brand_edit_suggestions"
            case subBrandEditSuggestions = "sub_brand_edit_suggestions"
        }

        public init(
            products: [Product.Joined],
            companies: [Company],
            brands: [Brand],
            subBrands: [SubBrand.JoinedBrand],
            barcodes: [Product.Barcode.Joined],
            reports: [Report],
            editSuggestions: [EditSuggestion]
        ) {
            self.products = products
            self.companies = companies
            self.brands = brands
            self.subBrands = subBrands
            self.barcodes = barcodes
            self.reports = reports
            self.editSuggestions = editSuggestions
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            products = try container.decode([Product.Joined].self, forKey: .products)
            companies = try container.decode([Company].self, forKey: .companies)
            brands = try container.decode([Brand].self, forKey: .brands)
            subBrands = try container.decode([SubBrand.JoinedBrand].self, forKey: .subBrands)
            barcodes = try container.decode([Product.Barcode.Joined].self, forKey: .barcodes)
            reports = try container.decode([Report].self, forKey: .reports)
            let productEditSuggestions: [EditSuggestion] = try container.decode([Product.EditSuggestion].self, forKey: .productEditSuggestions).map { .product($0) }
            let companyEditSuggestions: [EditSuggestion] = try container.decode([Company.EditSuggestion].self, forKey: .companyEditSuggestions).map { .company($0) }
            let brandEditSuggestions: [EditSuggestion] = try container.decode([Brand.EditSuggestion].self, forKey: .brandEditSuggestions).map { .brand($0) }
            let subBrandEditSuggestions: [EditSuggestion] = try container.decode([SubBrand.EditSuggestion].self, forKey: .subBrandEditSuggestions).map { .subBrand($0) }
            let editSuggestions = productEditSuggestions + companyEditSuggestions + brandEditSuggestions + subBrandEditSuggestions
            self.editSuggestions = editSuggestions.sorted(by: { $0.createdAt > $1.createdAt })
        }

        public func copyWith(
            products: [Product.Joined]? = nil,
            companies: [Company]? = nil,
            brands: [Brand]? = nil,
            subBrands: [SubBrand.JoinedBrand]? = nil,
            barcodes: [Product.Barcode.Joined]? = nil,
            reports: [Report]? = nil,
            editSuggestions: [EditSuggestion]? = nil
        ) -> Self {
            .init(
                products: products ?? self.products,
                companies: companies ?? self.companies,
                brands: brands ?? self.brands,
                subBrands: subBrands ?? self.subBrands,
                barcodes: barcodes ?? self.barcodes,
                reports: reports ?? self.reports,
                editSuggestions: editSuggestions ?? self.editSuggestions
            )
        }
    }
}

public enum EditSuggestion: Hashable, Identifiable, Sendable, Decodable {
    case product(Product.EditSuggestion)
    case company(Company.EditSuggestion)
    case brand(Brand.EditSuggestion)
    case subBrand(SubBrand.EditSuggestion)

    public var id: Int {
        hashValue
    }

    public var createdAt: Date {
        switch self {
        case let .brand(editSuggestion):
            editSuggestion.createdAt
        case let .product(editSuggestion):
            editSuggestion.createdAt
        case let .company(editSuggestion):
            editSuggestion.createdAt
        case let .subBrand(editSuggestion):
            editSuggestion.createdAt
        }
    }
}
