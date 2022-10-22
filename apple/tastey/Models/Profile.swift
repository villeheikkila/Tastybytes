import Foundation

struct Profile: Identifiable {
    let id: UUID
    let username: String
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    let nameDisplay: NameDisplay
    let colorScheme: ColorScheme?
    let notifications: [Notification]?
    let roles: [Role]?
}

extension Profile {
    func getPreferedName() -> String {
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
            let urlString = "\(Supabase.urlString)/storage/v1/object/public/\(bucketId)/\(avatarUrl)"
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

extension Profile {
    enum ColorScheme: String, CaseIterable, Decodable, Equatable {
        case system
        case light
        case dark
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
        case colorScheme = "color_scheme"
        case notification = "notifications"
        case roles = "roles"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        username = try values.decode(String.self, forKey: .username)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
        nameDisplay = try values.decode(NameDisplay.self, forKey: .nameDisplay)
        colorScheme = try values.decodeIfPresent(ColorScheme.self, forKey: .colorScheme)
        notifications = try values.decodeIfPresent([Notification].self, forKey: .notification)
        roles = try values.decodeIfPresent([Role].self, forKey: .roles)
    }
}

extension Profile {
    struct Update: Encodable {
        var username: String?
        var first_name: String?
        var last_name: String?
        var name_display: String?
        var color_scheme: String?

        init(showFullName: Bool) {
            name_display = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
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
