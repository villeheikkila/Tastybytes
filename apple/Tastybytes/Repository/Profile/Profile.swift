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

struct Profile: Identifiable, Decodable, Hashable, Sendable, AvatarURL {
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
  struct Extended: Identifiable, Decodable, Sendable, AvatarURL {
    let id: UUID
    let username: String
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
      username: String,
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
      firstName: String?? = nil,
      lastName: String?? = nil,
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
      Profile(id: id, preferredName: preferredName, isPrivate: isPrivate, avatarFile: avatarFile, joinedAt: joinedAt)
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
      username = try values.decode(String.self, forKey: .username)
      let joinedAtRaw = try values.decode(String.self, forKey: .joinedAt)

      if let date = CustomDateFormatter.shared.parse(string: joinedAtRaw, .date) {
        joinedAt = date
      } else {
        joinedAt = Date()
      }
      preferredName = try values.decode(String.self, forKey: .preferredName)
      isPrivate = try values.decode(Bool.self, forKey: .isPrivate)
      isOnboarded = try values.decode(Bool.self, forKey: .isOnboarded)
      firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
      lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
      avatarFile = try values.decodeIfPresent(String.self, forKey: .avatarFile)
      nameDisplay = try values.decode(NameDisplay.self, forKey: .nameDisplay)
      roles = try values.decode([Role].self, forKey: .roles)

      if let settings = try values.decode([ProfileSettings].self, forKey: .settings)
        .first
      {
        self.settings = settings
      } else {
        fatalError("failed to decode profile settings")
      }
    }
  }
}

extension Profile {
  enum NameDisplay: String, CaseIterable, Decodable, Equatable, Sendable {
    case username
    case fullName = "full_name"
  }

  struct UpdateRequest: Encodable, Sendable {
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

struct ProfileSettings: Identifiable, Decodable, Hashable, Sendable {
  let id: UUID
  let colorScheme: ColorScheme
  let sendReactionNotifications: Bool
  let sendTaggedCheckInNotifications: Bool
  let sendFriendRequestNotifications: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case colorScheme = "color_scheme"
    case sendReactionNotifications = "send_reaction_notifications"
    case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
    case sendFriendRequestNotifications = "send_friend_request_notifications"
  }
}

extension ProfileSettings {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "profile_settings"
    let saved =
      """
      id, color_scheme, send_reaction_notifications, send_tagged_check_in_notifications,\
      send_friend_request_notifications
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
  enum ColorScheme: String, CaseIterable, Decodable, Equatable, Sendable {
    case system
    case light
    case dark
  }

  struct UpdateRequest: Encodable, Sendable {
    var colorScheme: String?
    var sendReactionNotifications: Bool?
    var sendTaggedCheckInNotifications: Bool?
    var sendFriendRequestNotifications: Bool?

    enum CodingKeys: String, CodingKey {
      case colorScheme = "color_scheme"
      case sendReactionNotifications = "send_reaction_notifications"
      case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
      case sendFriendRequestNotifications = "send_friend_request_notifications"
    }

    init(sendReactionNotifications: Bool, sendTaggedCheckInNotifications: Bool, sendFriendRequestNotifications: Bool) {
      self.sendReactionNotifications = sendReactionNotifications
      self.sendTaggedCheckInNotifications = sendTaggedCheckInNotifications
      self.sendFriendRequestNotifications = sendFriendRequestNotifications
    }

    init(isDarkMode: Bool, isSystemColor: Bool) {
      if isSystemColor {
        colorScheme = ColorScheme.system.rawValue
      } else if isDarkMode {
        colorScheme = ColorScheme.dark.rawValue
      } else {
        colorScheme = ColorScheme.light.rawValue
      }
    }
  }
}

struct Contributions: Decodable, Sendable {
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

  struct ContributionsParams: Encodable, Sendable {
    let id: UUID

    enum CodingKeys: String, CodingKey {
      case id = "p_uid"
    }
  }

  enum QueryPart {
    case rpcName, value
  }

  static func getQuery(_ queryType: QueryPart) -> String {
    switch queryType {
    case .rpcName:
      return "fnc__get_contributions_by_user"
    case .value:
      return "products, companies, brands, sub_brands, barcodes"
    }
  }
}

struct CategoryStatistics: Identifiable, Decodable, Sendable, CategoryProtocol {
  let id: Int
  let name: String
  let icon: String
  let count: Int

  struct CategoryStatisticsParams: Encodable, Sendable {
    let id: UUID

    enum CodingKeys: String, CodingKey {
      case id = "p_user_id"
    }
  }

  enum QueryPart {
    case rpcName, value
  }

  static func getQuery(_ queryType: QueryPart) -> String {
    switch queryType {
    case .rpcName:
      return "fnc__get_category_stats"
    case .value:
      return "id, name, icon, count"
    }
  }
}

struct SubcategoryStatistics: Identifiable, Decodable, Sendable {
  let id: Int
  let name: String
  let count: Int

  struct SubcategoryStatisticsParams: Encodable, Sendable {
    let userId: UUID
    let categoryId: Int

    enum CodingKeys: String, CodingKey {
      case userId = "p_user_id"
      case categoryId = "p_category_id"
    }
  }

  enum QueryPart {
    case rpcName, value
  }

  static func getQuery(_ queryType: QueryPart) -> String {
    switch queryType {
    case .rpcName:
      return "fnc__get_subcategory_stats"
    case .value:
      return "id, name, count"
    }
  }
}

extension Profile {
  struct UsernameCheckRequest: Encodable, Sendable {
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
