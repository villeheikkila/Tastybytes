import Foundation

public struct CheckInComment: Identifiable, Hashable, Codable, Sendable {
    public let id: Int
    public let content: String
    public let createdAt: Date
    public let profile: Profile

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createdAt = "created_at"
        case profile = "profiles"
    }
}

public extension CheckInComment {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.checkInComments.rawValue
        let saved = "id, content, created_at"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedProfile(withTableName):
            return queryWithTableName(tableName, [saved, Profile.getQuery(.minimal(true))].joinComma(), withTableName)
        case let .joinedCheckIn(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case joinedProfile(_ withTableName: Bool)
        case joinedCheckIn(_ withTableName: Bool)
    }
}

public extension CheckInComment {
    struct Joined: Identifiable, Hashable, Codable, Sendable {
        public let id: Int
        public let content: String
        public let createdAt: Date
        public let profile: Profile
        public let checkIn: CheckIn

        enum CodingKeys: String, CodingKey {
            case id
            case content
            case createdAt = "created_at"
            case profile = "profiles"
            case checkIn = "check_ins"
        }
    }

    struct NewRequest: Codable, Sendable {
        public init(content: String, checkInId: Int) {
            self.content = content
            self.checkInId = checkInId
        }

        public let content: String
        public let checkInId: Int

        enum CodingKeys: String, CodingKey {
            case content, checkInId = "check_in_id"
        }
    }

    struct DeleteAsAdminRequest: Codable, Sendable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        public init(comment: CheckInComment) {
            id = comment.id
        }

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_comment_id"
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public init(id: Int, content: String) {
            self.id = id
            self.content = content
        }

        public let id: Int
        public let content: String
    }
}
