import Foundation

struct Profile: Identifiable, Hashable {
    let id: UUID
    let username: String
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    
    func getAvatarURL() -> URL? {
        if let avatarUrl = avatarUrl {
            let bucketId = "avatars"
            let urlString = "\(Supabase.urlString)/storage/v1/object/public/\(bucketId)/\(avatarUrl)"
            guard let url = URL(string: urlString) else { fatalError("Invalid URL") }
            return url
        } else {
            return nil
        }
    }

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
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        username = try values.decode(String.self, forKey: .username)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
    }
}

struct ProfileUpdate: Encodable {
    let username: String?
    let first_name: String?
    let last_name: String?
    
    init (username: String?, firstName: String?, lastName: String?) {
        self.username = username
        self.first_name = (firstName == nil || firstName?.isEmpty == true) ? nil : firstName
        self.last_name = (lastName == nil || lastName?.isEmpty == true) ? nil : lastName
    }
}

enum ProfileError: Error {
    case csvExportFailure
}
