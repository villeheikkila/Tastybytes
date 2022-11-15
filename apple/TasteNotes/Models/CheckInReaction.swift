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

extension CheckInReaction {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "check_in_reactions"
        let saved = "id"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedProfileCheckIn(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))), withTableName)
        case let .joinedProfile(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Profile.getQuery(.minimal(true))), withTableName)
        }
        
    }

    enum QueryType {
        case tableName
        case joinedProfile(_ withTableName: Bool)
        case joinedProfileCheckIn(_ withTableName: Bool)
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
    let p_check_in_id: Int

    init(checkInId: Int) {
        p_check_in_id = checkInId
    }
}
