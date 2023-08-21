public struct CheckInReaction: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let profile: Profile

    enum CodingKeys: String, CodingKey {
        case id
        case profile = "profiles"
    }
}

public extension CheckInReaction {
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

public extension CheckInReaction {
    struct JoinedCheckIn: Identifiable, Hashable, Codable, Sendable {
        public let id: Int
        public let profile: Profile
        public let checkIn: CheckIn

        enum CodingKeys: String, CodingKey {
            case id
            case profile = "profiles"
            case checkIn = "check_ins"
        }
    }
}

public extension CheckInReaction {
    struct NewRequest: Codable, Sendable {
        public init(checkInId: Int) {
            self.checkInId = checkInId
        }

        public let checkInId: Int

        enum CodingKeys: String, CodingKey {
            case checkInId = "p_check_in_id"
        }
    }

    struct DeleteRequest: Codable, Sendable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_reaction_id"
        }
    }
}
