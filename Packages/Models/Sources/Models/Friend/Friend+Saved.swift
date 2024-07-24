import Foundation
public import Tagged

public extension Friend {
    struct Saved: Identifiable, Codable, Hashable, Sendable {
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
}
