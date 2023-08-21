import Foundation
import SFSafeSymbols

public struct Notification: Identifiable, Hashable {
    public enum Content: Hashable {
        case message(String)
        case friendRequest(Friend)
        case taggedCheckIn(CheckIn)
        case checkInReaction(CheckInReaction.JoinedCheckIn)
        case checkInComment(CheckInComment.Joined)
    }

    public let id: Int
    public let createdAt: Date
    public let seenAt: Date?
    public let content: Content

    public var isFriendRequest: Bool {
        if case .friendRequest = content {
            return true
        }

        return false
    }

    public func copyWith(id: Int? = nil, createdAt: Date? = nil, seenAt: Date?? = nil,
                         content: Content? = nil) -> Notification
    {
        return Notification(id: id ?? self.id,
                            createdAt: createdAt ?? self.createdAt,
                            seenAt: seenAt ?? self.seenAt,
                            content: content ?? self.content)
    }
}

public extension Notification {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.notifications.rawValue
        let saved = "id, message, created_at, seen_at"

        switch queryType {
        case .tableName:
            return tableName
        case .joined:
            return [
                saved,
                CheckInReaction.getQuery(.joinedProfileCheckIn(true)),
                CheckInTaggedProfiles.getQuery(.joined(true)),
                Friend.getQuery(.joined(true)),
                CheckInComment.getQuery(.joinedCheckIn(true)),
            ].joinComma()
        }
    }

    enum QueryType {
        case tableName
        case joined
    }
}

extension Notification: Codable {
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
        id = try values.decode(Int.self, forKey: .id)

        let timestamp = try values.decode(String.self, forKey: .createdAt)
        if let createdAt = Date(timestamptzString: timestamp) {
            self.createdAt = createdAt
        } else {
            throw DateParsingError.unsupportedFormat
        }

        if let date = try values.decodeIfPresent(String.self, forKey: .seenAt) {
            seenAt = Date(timestamptzString: date)
        } else {
            seenAt = nil
        }

        let message = try values.decodeIfPresent(String.self, forKey: .message)
        let friendRequest = try values.decodeIfPresent(Friend.self, forKey: .friendRequest)
        let taggedCheckIn = try values.decodeIfPresent(CheckInTaggedProfiles.self, forKey: .taggedCheckIn)
        let checkInReaction = try values.decodeIfPresent(CheckInReaction.JoinedCheckIn.self, forKey: .checkInReaction)
        let checkInComment = try values.decodeIfPresent(CheckInComment.Joined.self, forKey: .checkInComments)

        if let message {
            content = Notification.Content.message(message)
        } else if let friendRequest {
            content = Notification.Content.friendRequest(friendRequest)
        } else if let checkIn = taggedCheckIn?.checkIn {
            content = Notification.Content.taggedCheckIn(checkIn)
        } else if let checkInReaction {
            content = Notification.Content.checkInReaction(checkInReaction)
        } else if let checkInComment {
            content = Notification.Content.checkInComment(checkInComment)
        } else {
            content = Notification.Content.message("No content")
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

public extension Notification {
    struct CheckInTaggedProfiles: Identifiable, Codable {
        public let id: Int
        public let checkIn: CheckIn

        enum CodingKeys: String, CodingKey {
            case id
            case checkIn = "check_ins"
        }

        public static func getQuery(_ queryType: QueryType) -> String {
            let tableName = Database.Table.checkInTaggedProfiles.rawValue
            let saved = "id"

            switch queryType {
            case .tableName:
                return tableName
            case let .joined(withTableName):
                return queryWithTableName(
                    tableName,
                    [saved, CheckIn.getQuery(.joined(true))].joinComma(),
                    withTableName
                )
            }
        }

        public enum QueryType {
            case tableName
            case joined(_ withTableName: Bool)
        }
    }

    struct MarkReadRequest: Codable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_notification_id"
        }
    }

    struct MarkCheckInReadRequest: Codable {
        public init(checkInId: Int) {
            self.checkInId = checkInId
        }

        public let checkInId: Int

        enum CodingKeys: String, CodingKey {
            case checkInId = "p_check_in_id"
        }
    }
}

public enum NotificationType: String, CaseIterable, Identifiable, Sendable {
    public var id: Self {
        self
    }

    case message, friendRequest, taggedCheckIn, checkInReaction, checkInComment

    public var label: String {
        switch self {
        case .message:
            "Alerts"
        case .friendRequest:
            "Friend Requests"
        case .taggedCheckIn:
            "Tagged check-ins"
        case .checkInReaction:
            "Reactions"
        case .checkInComment:
            "Comments"
        }
    }

    public var systemSymbol: SFSymbol {
        switch self {
        case .message:
            .bell
        case .friendRequest:
            .personBadgePlus
        case .taggedCheckIn:
            .tag
        case .checkInReaction:
            .handThumbsup
        case .checkInComment:
            .bubbleLeft
        }
    }
}

public struct ProfilePushNotification: Codable, Identifiable {
    public let id: String
    public let sendReactionNotifications: Bool
    public let sendTaggedCheckInNotifications: Bool
    public let sendFriendRequestNotifications: Bool
    public let sendCheckInCommentNotifications: Bool

    enum CodingKeys: String, CodingKey {
        case id = "firebase_registration_token"
        case sendReactionNotifications = "send_reaction_notifications"
        case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
        case sendFriendRequestNotifications = "send_friend_request_notifications"
        case sendCheckInCommentNotifications = "send_comment_notifications"
    }

    public func copyWith(
        sendReactionNotifications: Bool? = nil,
        sendTaggedCheckInNotifications: Bool? = nil,
        sendFriendRequestNotifications: Bool? = nil,
        sendCheckInCommentNotifications: Bool? = nil
    ) -> ProfilePushNotification {
        ProfilePushNotification(id: id,
                                sendReactionNotifications: sendReactionNotifications ?? self.sendReactionNotifications,
                                sendTaggedCheckInNotifications: sendTaggedCheckInNotifications ?? self
                                    .sendTaggedCheckInNotifications,
                                sendFriendRequestNotifications: sendFriendRequestNotifications ?? self
                                    .sendFriendRequestNotifications,
                                sendCheckInCommentNotifications: sendCheckInCommentNotifications ?? self
                                    .sendCheckInCommentNotifications)
    }

    public static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profilePushNotifications.rawValue
        let saved =
            "firebase_registration_token, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications, send_friend_request_notifications, send_comment_notifications"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    public enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
