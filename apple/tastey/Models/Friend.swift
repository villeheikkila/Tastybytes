import Foundation

struct Friend: Identifiable {
    let id: Int
    let sender: Profile
    let receiver: Profile
    let status: FriendStatus
    
    func getFriend(userId: UUID) -> Profile {
        if (sender.id == userId) {
            return receiver
        } else {
            return sender
        }
    }
}

extension Friend: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case receiver
        case status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        sender = try values.decode(Profile.self, forKey: .sender)
        receiver = try values.decode(Profile.self, forKey: .receiver)
        status = try values.decode(FriendStatus.self, forKey: .status)
    }
}

struct NewFriend: Encodable {
    let user_id_1: UUID
    let user_id_2: UUID
    
    init(sender: UUID, receiver: UUID) {
        self.user_id_1 = sender
        self.user_id_2 = receiver
    }
}

enum FriendStatus: String, Codable{
    case pending, accepted, blocked
}
