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
