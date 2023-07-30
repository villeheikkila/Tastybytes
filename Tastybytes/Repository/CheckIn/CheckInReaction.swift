struct CheckInReaction: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let profile: Profile

    enum CodingKeys: String, CodingKey {
        case id
        case profile = "profiles"
    }
}

extension CheckInReaction {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.checkInReactions.rawValue
        let saved = "id"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedProfileCheckIn(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        case let .joinedProfile(withTableName):
            return queryWithTableName(tableName, [saved, Profile.getQuery(.minimal(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joinedProfile(_ withTableName: Bool)
        case joinedProfileCheckIn(_ withTableName: Bool)
    }
}

extension CheckInReaction {
    struct JoinedCheckIn: Identifiable, Hashable, Codable, Sendable {
        let id: Int
        let profile: Profile
        let checkIn: CheckIn

        enum CodingKeys: String, CodingKey {
            case id
            case profile = "profiles"
            case checkIn = "check_ins"
        }
    }
}

extension CheckInReaction {
    struct NewRequest: Codable, Sendable {
        let checkInId: Int

        enum CodingKeys: String, CodingKey {
            case checkInId = "p_check_in_id"
        }
    }

    struct DeleteRequest: Codable, Sendable {
        let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_reaction_id"
        }
    }
}
