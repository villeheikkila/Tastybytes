import Foundation

struct CheckInReaction: Identifiable, Hashable {
    let id: Int
    let createdBy: UUID
    let profiles: Profile

    static func == (lhs: CheckInReaction, rhs: CheckInReaction) -> Bool {
        return lhs.id == rhs.id
    }
}

extension CheckInReaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createdBy = "created_by"
        case profiles
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        createdBy = try values.decode(UUID.self, forKey: .createdBy)
        profiles = try values.decode(Profile.self, forKey: .profiles)
    }
}


struct NewCheckInReaction: Encodable {
    let check_in_id: Int
    let created_by: UUID
    
    init(checkInId: Int, createdBy: UUID) {
        self.check_in_id = checkInId
        self.created_by = createdBy
    }
}
