import Foundation

struct Profile: Identifiable, Decodable, Hashable {
  let id: UUID
  let preferredName: String
  var avatarUrl: String?

  enum CodingKeys: String, CodingKey, CaseIterable {
    case id
    case preferredName = "preferred_name"
    case avatarUrl = "avatar_url"
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(preferredName)
    hasher.combine(avatarUrl)
  }

  static func == (lhs: Profile, rhs: Profile) -> Bool {
    lhs.id == rhs.id
  }
}

extension Profile {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "profiles"
    let minimal = "id, preferred_name, avatar_url"
    let saved = "id, preferred_name, username, first_name, last_name, avatar_url, name_display"

    switch queryType {
    case .tableName:
      return tableName
    case let .minimal(withTableName):
      return queryWithTableName(tableName, minimal, withTableName)
    case let .extended(withTableName):
      return queryWithTableName(
        tableName,
        joinWithComma(saved, ProfileSettings.getQuery(.saved(true)), Role.getQuery(.joined(true))),
        withTableName
      )
    }
  }

  enum QueryType {
    case tableName
    case minimal(_ withTableName: Bool)
    case extended(_ withTableName: Bool)
  }
}

extension Profile {
  struct Extended: Identifiable, Decodable {
    let id: UUID
    let username: String
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    let preferredName: String
    let nameDisplay: NameDisplay
    let roles: [Role]
    let settings: ProfileSettings

    func getProfile() -> Profile {
      Profile(id: id, preferredName: preferredName, avatarUrl: avatarUrl)
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
      case id
      case username
      case preferredName = "preferred_name"
      case firstName = "first_name"
      case lastName = "last_name"
      case avatarUrl = "avatar_url"
      case nameDisplay = "name_display"
      case notification = "notifications"
      case roles
      case settings = "profile_settings"
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(UUID.self, forKey: .id)
      username = try values.decode(String.self, forKey: .username)
      preferredName = try values.decode(String.self, forKey: .preferredName)
      firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
      lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
      avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
      nameDisplay = try values.decode(NameDisplay.self, forKey: .nameDisplay)
      roles = try values.decode([Role].self, forKey: .roles)
      settings = try values.decode([ProfileSettings].self, forKey: .settings)
        .first! // TODO: Fix this when PostgREST 10 is used by Supabase
    }
  }
}

extension Profile {
  func getAvatarURL() -> URL? {
    if let avatarUrl {
      let supabaseUrl = Config.supabaseUrl.absoluteString
      let bucketId = "avatars"
      let urlString =
        "\(supabaseUrl)/storage/v1/object/public/\(bucketId)/\(id.uuidString.lowercased())/\(avatarUrl)"
      return URL(string: urlString)
    } else {
      return nil
    }
  }
}

extension Profile {
  enum NameDisplay: String, CaseIterable, Decodable, Equatable {
    case username
    case fullName = "full_name"
  }

  struct UpdateRequest: Encodable {
    var username: String?
    var firstName: String?
    var lastName: String?
    var nameDisplay: String?

    enum CodingKeys: String, CodingKey {
      case username
      case firstName = "first_name"
      case lastName = "last_name"
      case nameDisplay = "name_display"
    }

    init(showFullName: Bool) {
      nameDisplay = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
    }

    init(username: String?, firstName: String?, lastName: String?) {
      self.username = username
      self.firstName = firstName
      self.lastName = lastName
    }
  }
}

enum ProfileError: Error {
  case csvExportFailure
}

struct ProfileSettings: Identifiable, Decodable, Hashable {
  let id: UUID
  let colorScheme: ColorScheme
  let sendReactionNotifications: Bool
  let sendTaggedCheckInNotifications: Bool
  let sendFriendRequestNotifications: Bool
  let publicProfile: Bool

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(colorScheme)
    hasher.combine(sendReactionNotifications)
    hasher.combine(sendTaggedCheckInNotifications)
    hasher.combine(sendFriendRequestNotifications)
    hasher.combine(publicProfile)
  }

  static func == (lhs: ProfileSettings, rhs: ProfileSettings) -> Bool {
    lhs.id == rhs.id
  }

  enum CodingKeys: String, CodingKey {
    case id
    case colorScheme = "color_scheme"
    case sendReactionNotifications = "send_reaction_notifications"
    case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
    case sendFriendRequestNotifications = "send_friend_request_notifications"
    case publicProfile = "public_profile"
  }
}

extension ProfileSettings {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "profile_settings"
    let saved =
      """
      id, color_scheme, send_reaction_notifications, send_tagged_check_in_notifications,\
              send_friend_request_notifications, public_profile
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
  enum ColorScheme: String, CaseIterable, Decodable, Equatable {
    case system
    case light
    case dark
  }

  struct UpdateRequest: Encodable {
    var colorScheme: String?
    var sendReactionNotifications: Bool?
    var sendTaggedCheckInNotifications: Bool?
    var sendFriendRequestNotifications: Bool?
    var publicProfile: Bool?

    enum CodingKeys: String, CodingKey {
      case colorScheme = "color_scheme"
      case sendReactionNotifications = "send_reaction_notifications"
      case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
      case sendFriendRequestNotifications = "send_friend_request_notifications"
      case publicProfile = "public_profile"
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

    init(publicProfile: Bool) {
      self.publicProfile = publicProfile
    }
  }
}

extension Profile {
  struct PushNotificationToken: Identifiable, Codable, Hashable {
    var id: String { firebaseRegistrationToken }
    let firebaseRegistrationToken: String

    init(firebaseRegistrationToken: String) {
      self.firebaseRegistrationToken = firebaseRegistrationToken
    }

    static func == (lhs: PushNotificationToken, rhs: PushNotificationToken) -> Bool {
      lhs.firebaseRegistrationToken == rhs.firebaseRegistrationToken
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
