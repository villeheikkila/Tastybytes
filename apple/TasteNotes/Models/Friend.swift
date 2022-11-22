import Foundation

struct Friend: Identifiable {
    let id: Int
    let sender: Profile
    let receiver: Profile
    let status: Status
    let blockedBy: UUID?

    func getFriend(userId: UUID?) -> Profile {
        if sender.id == userId {
            return receiver
        } else {
            return sender
        }
    }

    func isPending(userId: UUID) -> Bool {
        return receiver.id == userId && status == Status.pending
    }

    func isBlocked(userId: UUID) -> Bool {
        return blockedBy != nil && blockedBy != userId
    }

    func containsUser(userId: UUID) -> Bool {
        return sender.id == userId || receiver.id == userId
    }
}

extension Friend: Hashable {
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.id == rhs.id && lhs.status == rhs.status
    }
}

extension Friend: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case receiver
        case status
        case blockedBy = "blocked_by"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        sender = try values.decode(Profile.self, forKey: .sender)
        receiver = try values.decode(Profile.self, forKey: .receiver)
        status = try values.decode(Status.self, forKey: .status)
        blockedBy = try values.decodeIfPresent(UUID.self, forKey: .blockedBy)
    }
}

extension Friend {
    enum Status: String, Codable {
        case pending, accepted, blocked
    }

    struct NewRequest: Encodable {
        let user_id_2: UUID
        let status: String
        init(receiver: UUID, status: Status) {
            user_id_2 = receiver
            self.status = Status.pending.rawValue
        }
    }

    struct UpdateRequest: Encodable {
        let user_id_1: UUID
        let user_id_2: UUID
        let status: String

        init(user_id_1: UUID, user_id_2: UUID, status: Status) {
            self.user_id_1 = user_id_1
            self.user_id_2 = user_id_2
            self.status = status.rawValue
        }
    }
}

extension Friend {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "friends"
        let joined = "id, status, sender:user_id_1 (\(Profile.getQuery(.minimal(false)))), receiver:user_id_2 (\(Profile.getQuery(.minimal(false))))"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(tableName, joined, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}

