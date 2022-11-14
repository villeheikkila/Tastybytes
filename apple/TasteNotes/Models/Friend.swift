import Foundation

struct Friend: Identifiable {
    let id: Int
    let sender: Profile
    let receiver: Profile
    let status: FriendStatus
    let blockedBy: UUID?
    
    func getFriend(userId: UUID?) -> Profile {
        if (sender.id == userId) {
            return receiver
        } else {
            return sender
        }
    }
    
    func isPending(userId: UUID) -> Bool {
        return self.receiver.id == userId && self.status == FriendStatus.pending
    }
    
    func isBlocked(userId: UUID) -> Bool {
        return self.blockedBy != nil && self.blockedBy != userId
    }
    
    func containsUser(userId: UUID) -> Bool {
        return sender.id == userId || receiver.id == userId
    }
}

enum FriendStatus: String, Codable{
    case pending, accepted, blocked
}

extension Friend: Hashable {
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.id == rhs.id && lhs.status == rhs.status
    }
}

extension Friend {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "friends"
        let joined = "id, status, sender:user_id_1 (\(Profile.getQuery(.saved(false)))), receiver:user_id_2 (\(Profile.getQuery(.saved(false))))"

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
        status = try values.decode(FriendStatus.self, forKey: .status)
        blockedBy = try values.decodeIfPresent(UUID.self, forKey: .blockedBy)
    }
}

struct NewFriend: Encodable {
    let user_id_2: UUID
    let status: String
    init(receiver: UUID, status: FriendStatus) {
        self.user_id_2 = receiver
        self.status = FriendStatus.pending.rawValue
    }
}

struct FriendUpdate: Encodable {
    let user_id_1: UUID
    let user_id_2: UUID
    let status: String
    
    
    init(user_id_1: UUID, user_id_2: UUID, status: FriendStatus) {
        self.user_id_1 = user_id_1
        self.user_id_2 = user_id_2
        self.status = status.rawValue
    }
}
