import Foundation

struct Notification: Identifiable {
    let id: Int
    let message: String
    let createdAt: Date
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
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        message = try values.decode(String.self, forKey: .message)
        createdAt = try parseDate(from: try values.decode(String.self, forKey: .createdAt))
    }
}

