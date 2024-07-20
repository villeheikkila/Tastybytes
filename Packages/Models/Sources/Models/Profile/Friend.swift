import Foundation
import Tagged

public struct Friend: Identifiable, Codable, Hashable, Sendable {
    public let id: Friend.Id
    public let sender: Profile
    public let receiver: Profile
    public let status: Status
    public let blockedBy: Profile.Id?

    enum CodingKeys: String, CodingKey {
        case id
        case sender
        case receiver
        case status
        case blockedBy = "blocked_by"
    }

    public func getFriend(userId: Profile.Id?) -> Profile {
        if sender.id == userId {
            receiver
        } else {
            sender
        }
    }

    public func isPending(userId: Profile.Id) -> Bool {
        receiver.id == userId && status == Status.pending
    }

    public func isBlocked(userId: Profile.Id) -> Bool {
        blockedBy != nil && blockedBy != userId
    }

    public func containsUser(userId: Profile.Id) -> Bool {
        sender.id == userId || receiver.id == userId
    }
}

public extension Friend {
    typealias Id = Tagged<Friend, Int>
}

public extension Friend {
    enum Status: String, Codable, Sendable {
        case pending, accepted, blocked
    }

    struct NewRequest: Codable, Sendable {
        public init(receiver: Profile.Id, status: Status) {
            receiverId = receiver
            self.status = status.rawValue
        }

        public let receiverId: Profile.Id
        public let status: String

        enum CodingKeys: String, CodingKey {
            case receiverId = "user_id_2", status
        }

        public init(receiver: Profile.Id) {
            receiverId = receiver
            status = Status.pending.rawValue
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let senderId: Profile.Id
        public let receiverId: Profile.Id
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
