import Foundation

struct CheckInReaction: Identifiable {
    let id: Int
    let profile: Profile
}

extension CheckInReaction: Hashable {
    static func == (lhs: CheckInReaction, rhs: CheckInReaction) -> Bool {
        return lhs.id == rhs.id
    }
}

extension CheckInReaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case profile = "profiles"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        profile = try values.decode(Profile.self, forKey: .profile)
    }
}

struct CheckInReactionWithCheckIn: Identifiable {
    let id: Int
    let profile: Profile
    let checkIn: CheckIn
}

extension CheckInReactionWithCheckIn: Hashable {
    static func == (lhs: CheckInReactionWithCheckIn, rhs: CheckInReactionWithCheckIn) -> Bool {
        return lhs.id == rhs.id
    }
}

extension CheckInReactionWithCheckIn: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case profile = "profiles"
        case checkIn = "check_ins"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        profile = try values.decode(Profile.self, forKey: .profile)
        checkIn = try values.decode(CheckIn.self, forKey: .checkIn)
    }
}



struct NewCheckInReaction: Encodable {
    let check_in_id: Int
    
    init(checkInId: Int) {
        self.check_in_id = checkInId
    }
}
