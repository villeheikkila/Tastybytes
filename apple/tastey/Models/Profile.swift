import Foundation

struct Profile: Identifiable {
    let id: UUID
    let username: String
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    let nameDisplay: NameDisplay


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
        return [firstName, lastName]
            .compactMap({ $0 })
            .joined(separator: " ")
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
        return currentUserId == self.id
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
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        username = try values.decode(String.self, forKey: .username)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
        nameDisplay = try values.decode(NameDisplay.self, forKey: .nameDisplay)
    }
}

struct ProfileUpdate: Encodable {
    var username: String?
    var first_name: String?
    var last_name: String?
    var name_display: String?

    init(showFullName: Bool) {
        name_display = showFullName ? Profile.NameDisplay.fullName.rawValue : Profile.NameDisplay.username.rawValue
    }

    init(username: String?, firstName: String?, lastName: String?) {
        self.username = username
        first_name = (firstName == nil || firstName?.isEmpty == true) ? nil : firstName
        last_name = (lastName == nil || lastName?.isEmpty == true) ? nil : lastName
    }
}

enum ProfileError: Error {
    case csvExportFailure
}
