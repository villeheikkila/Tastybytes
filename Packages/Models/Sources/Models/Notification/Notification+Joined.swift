import Foundation
public import Tagged

public extension Notification {
    struct Joined: Identifiable, Hashable, Sendable, Codable {
        public let id: Notification.Id
        public let createdAt: Date
        public let seenAt: Date?
        public let content: Content

        init(id: Notification.Id, createdAt: Date, seenAt: Date? = nil, content: Notification.Content) {
            self.id = id
            self.createdAt = createdAt
            self.seenAt = seenAt
            self.content = content
        }

        public var isFriendRequest: Bool {
            if case .friendRequest = content {
                return true
            }
            return false
        }

        public func copyWith(createdAt: Date? = nil, seenAt: Date?? = nil,
                             content: Content? = nil) -> Self
        {
            .init(id: id,
                  createdAt: createdAt ?? self.createdAt,
                  seenAt: seenAt ?? self.seenAt,
                  content: content ?? self.content)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case message
            case createdAt = "created_at"
            case seenAt = "seen_at"
            case friendRequest = "friends"
            case taggedCheckIn = "check_in_tagged_profiles"
            case checkInReaction = "check_in_reactions"
            case checkInComments = "check_in_comments"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Notification.Id.self, forKey: .id)
            createdAt = try values.decode(Date.self, forKey: .createdAt)
            seenAt = try values.decodeIfPresent(Date.self, forKey: .seenAt)

            let message = try values.decodeIfPresent(String.self, forKey: .message)
            let friendRequest = try values.decodeIfPresent(Friend.Saved.self, forKey: .friendRequest)
            let taggedCheckIn = try values.decodeIfPresent(CheckInTaggedProfiles.self, forKey: .taggedCheckIn)
            let checkInReaction = try values.decodeIfPresent(CheckIn.Reaction.JoinedCheckIn.self, forKey: .checkInReaction)
            let checkInComment = try values.decodeIfPresent(CheckIn.Comment.Joined.self, forKey: .checkInComments)

            content = if let message {
                .message(message)
            } else if let friendRequest {
                .friendRequest(friendRequest)
            } else if let checkIn = taggedCheckIn?.checkIn {
                .taggedCheckIn(checkIn)
            } else if let checkInReaction {
                .checkInReaction(checkInReaction)
            } else if let checkInComment {
                .checkInComment(checkInComment)
            } else {
                .message("No content")
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encodeIfPresent(seenAt, forKey: .seenAt)

            switch content {
            case let .message(message):
                try container.encodeIfPresent(message, forKey: .message)
            case let .friendRequest(friendRequest):
                try container.encodeIfPresent(friendRequest, forKey: .friendRequest)
            case let .taggedCheckIn(checkIn):
                try container.encodeIfPresent(CheckInTaggedProfiles(id: id, checkIn: checkIn), forKey: .taggedCheckIn)
            case let .checkInReaction(reaction):
                try container.encodeIfPresent(reaction, forKey: .checkInReaction)
            case let .checkInComment(comment):
                try container.encodeIfPresent(comment, forKey: .checkInComments)
            }
        }
    }
}
