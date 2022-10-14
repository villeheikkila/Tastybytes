import Foundation

struct CheckInComment: Identifiable, Hashable {
    let id: Int
    var content: String
    let createdAt: String
    let profiles: Profile
        
    static func == (lhs: CheckInComment, rhs: CheckInComment) -> Bool {
        return lhs.id == rhs.id
    }
}

extension CheckInComment: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createdAt = "created_at"
        case profiles
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        content = try values.decode(String.self, forKey: .content)
        createdAt = try values.decode(String.self, forKey: .createdAt)
        profiles = try values.decode(Profile.self, forKey: .profiles)
    }
}


struct NewCheckInComment: Encodable {
    let content: String
    let created_by: String
    let check_in_id: Int
    
    init(content: String, createdBy: UUID, checkInId: Int) {
        self.content = content
        self.created_by = createdBy.uuidString
        self.check_in_id = checkInId
    }
}

struct UpdateCheckInComment: Encodable {
    let content: String
}
