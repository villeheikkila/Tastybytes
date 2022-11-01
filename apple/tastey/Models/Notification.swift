import Foundation

enum NotificationContent: Hashable {
    case message(String)
    case friendRequest(Friend)
    case taggedCheckIn(CheckIn)
    case checkInReaction(CheckInReactionWithCheckIn)
}
struct Notification: Identifiable {
    let id: Int
    let createdAt: Date
    let content: NotificationContent?
}

extension Notification: Hashable {
    static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Notification: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case message
        case createdAt = "created_at"
        case friendRequest = "friends"
        case taggedCheckIn = "check_ins"
        case checkInReaction = "check_in_reactions"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        createdAt = try parseDate(from: try values.decode(String.self, forKey: .createdAt))
        let message = try values.decodeIfPresent(String.self, forKey: .message)
        let friendRequest = try values.decodeIfPresent(Friend.self, forKey: .friendRequest)
        let taggedCheckIn = try values.decodeIfPresent(CheckIn.self, forKey: .taggedCheckIn)
        let checkInReaction = try values.decodeIfPresent(CheckInReactionWithCheckIn.self, forKey: .checkInReaction)
        
        if let message = message {
            self.content = NotificationContent.message(message)
        } else if let friendRequest = friendRequest {
            self.content = NotificationContent.friendRequest(friendRequest)
        } else if let taggedCheckIn = taggedCheckIn {
            self.content = NotificationContent.taggedCheckIn(taggedCheckIn)
        } else if let checkInReaction = checkInReaction {
            self.content = NotificationContent.checkInReaction(checkInReaction)
        } else {
            self.content = nil
        }
    }
}

