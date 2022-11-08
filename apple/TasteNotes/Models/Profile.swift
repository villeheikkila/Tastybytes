import Foundation

struct Profile: Identifiable {
    let id: UUID
    let username: String
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    let nameDisplay: NameDisplay
    let notifications: [Notification]?
    let roles: [Role]?
    let settings: ProfileSettings?
}

extension Profile {
    func getPreferredName() -> String {
        switch nameDisplay {
        case .username:
            return username
        case .fullName:
            return getFullName()
        }
    }
    
    func getFullName() -> String {
        if let firstName = firstName, let lastName = lastName {
            let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            let formattedFullName = [trimmedFirstName, trimmedLastName]
                .compactMap({ $0 })
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return formattedFullName.isEmpty ? username : formattedFullName
        } else {
            return username
        }
    }
    
    func getAvatarURL() -> URL? {
        if let avatarUrl = avatarUrl {
            let bucketId = "avatars"
            let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId)/\(self.id.uuidString.lowercased())/\(avatarUrl)"
            guard let url = URL(string: urlString) else { return nil }
            return url
        } else {
            return nil
        }
    }
    
    func isCurrentUser() -> Bool {
        let currentUserId = repository.auth.getCurrentUserId()
        return currentUserId == id
    }
}

extension Profile {
    enum NameDisplay: String, CaseIterable, Decodable, Equatable {
        case username
        case fullName = "full_name"
    }
}

extension Profile: Hashable {
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Profile: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarUrl = "avatar_url"
        case nameDisplay = "name_display"
        case notification = "notifications"
        case roles = "roles"
        case settings = "profile_settings"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        username = try values.decode(String.self, forKey: .username)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
        nameDisplay = try values.decode(NameDisplay.self, forKey: .nameDisplay)
        notifications = try values.decodeIfPresent([Notification].self, forKey: .notification)
        roles = try values.decodeIfPresent([Role].self, forKey: .roles)
        settings = try values.decodeIfPresent([ProfileSettings].self, forKey: .settings)?.first
    }
}

extension Profile {
    struct Update: Encodable {
        var username: String?
        var first_name: String?
        var last_name: String?
        var name_display: String?
        
        init(showFullName: Bool) {
            name_display = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
        }
        
        init(username: String?, firstName: String?, lastName: String?) {
            self.username = username
            first_name = firstName
            last_name = lastName
        }
    }
}

enum ProfileError: Error {
    case csvExportFailure
}

struct ProfileSettings: Identifiable, Decodable, Hashable {
    let id: UUID
    let colorScheme: ColorScheme?
    let sendReactionNotifications: Bool
    let sendTaggedCheckInNotifications: Bool
    let sendFriendRequestNotifications: Bool
    
    static func == (lhs: ProfileSettings, rhs: ProfileSettings) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case colorScheme = "color_scheme"
        case sendReactionNotifications = "send_reaction_notifications"
        case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
        case sendFriendRequestNotifications = "send_friend_request_notifications"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        colorScheme = try values.decodeIfPresent(ColorScheme.self, forKey: .colorScheme)
        sendReactionNotifications = try values.decode(Bool.self, forKey: .sendReactionNotifications)
        sendTaggedCheckInNotifications = try values.decode(Bool.self, forKey: .sendTaggedCheckInNotifications)
        sendFriendRequestNotifications = try values.decode(Bool.self, forKey: .sendFriendRequestNotifications)

    }
}

extension ProfileSettings {
    enum ColorScheme: String, CaseIterable, Decodable, Equatable {
        case system
        case light
        case dark
    }
    
    struct Update: Encodable {
        var username: String?
        var send_reaction_notifications: Bool?
        var send_tagged_check_in_notifications: Bool?
        var send_friend_request_notifications: Bool?
        var color_scheme: String?
        
        init(sendReactionNotifications: Bool, sendTaggedCheckInNotifications: Bool, sendFriendRequestNotifications: Bool) {
            self.send_reaction_notifications = sendReactionNotifications
            self.send_tagged_check_in_notifications = sendTaggedCheckInNotifications
            self.send_friend_request_notifications = sendFriendRequestNotifications
        }
        
        init(isDarkMode: Bool, isSystemColor: Bool) {
            if isSystemColor {
                color_scheme = ColorScheme.system.rawValue
            } else if isDarkMode {
                color_scheme = ColorScheme.dark.rawValue
            } else {
                color_scheme = ColorScheme.light.rawValue
            }
        }
    }
}

extension Profile {
    struct PushNotificationToken: Identifiable, Codable, Hashable {
        var id: String { firebaseRegistrationToken }
        let firebaseRegistrationToken: String
        let updatedAt: Date
        
        init(firebaseRegistrationToken: String) {
            self.firebaseRegistrationToken = firebaseRegistrationToken
            self.updatedAt = Date()
        }
        
        static func == (lhs: PushNotificationToken, rhs: PushNotificationToken) -> Bool {
            return lhs.firebaseRegistrationToken == rhs.firebaseRegistrationToken
        }
        
        enum CodingKeys: String, CodingKey {
            case firebaseRegistrationToken = "firebase_registration_token"
            case updatedAt = "updated_at"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            firebaseRegistrationToken = try values.decode(String.self, forKey: .firebaseRegistrationToken)
            updatedAt = try parseDate(from: try values.decode(String.self, forKey: .updatedAt))
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(firebaseRegistrationToken, forKey: .firebaseRegistrationToken)
            try container.encode(updatedAt, forKey: .updatedAt)
        }
    }
}
