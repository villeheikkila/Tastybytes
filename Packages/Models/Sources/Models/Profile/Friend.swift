import Foundation

public struct Friend: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let sender: Profile
    public let receiver: Profile
    public let status: Status
    public let blockedBy: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case receiver
        case status
        case blockedBy = "blocked_by"
    }

    public func getFriend(userId: UUID?) -> Profile {
        if sender.id == userId {
            receiver
        } else {
            sender
        }
    }

    public func isPending(userId: UUID) -> Bool {
        receiver.id == userId && status == Status.pending
    }

    public func isBlocked(userId: UUID) -> Bool {
        blockedBy != nil && blockedBy != userId
    }

    public func containsUser(userId: UUID) -> Bool {
        sender.id == userId || receiver.id == userId
    }
}

public extension Friend {
    enum Status: String, Codable, Sendable {
        case pending, accepted, blocked
    }

    struct NewRequest: Codable, Sendable {
        public init(receiver: UUID, status: Status) {
            receiverId = receiver
            self.status = status.rawValue
        }

        public let receiverId: UUID
        public let status: String

        enum CodingKeys: String, CodingKey {
            case receiverId = "user_id_2", status
        }

        public init(receiver: UUID) {
            receiverId = receiver
            status = Status.pending.rawValue
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let senderId: UUID
        public let receiverId: UUID
        public let status: String

        enum CodingKeys: String, CodingKey {
            case senderId = "user_id_1", receiverId = "user_id_2", status
        }

        public init(sender: Profile, receiver: Profile, status: Status) {
            senderId = sender.id
            receiverId = receiver.id
            self.status = status.rawValue
        }
    }
}
