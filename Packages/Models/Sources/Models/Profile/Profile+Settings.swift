public import Tagged

public extension Profile {
    struct Settings: Identifiable, Codable, Hashable, Sendable {
        public let id: Profile.Id
        public let sendReactionNotifications: Bool
        public let sendTaggedCheckInNotifications: Bool
        public let sendFriendRequestNotifications: Bool
        public let sendCommentNotifications: Bool

        public init(
            id: Profile.Id,
            sendReactionNotifications: Bool,
            sendTaggedCheckInNotifications: Bool,
            sendFriendRequestNotifications: Bool,
            sendCommentNotifications: Bool
        ) {
            self.id = id
            self.sendReactionNotifications = sendReactionNotifications
            self.sendTaggedCheckInNotifications = sendTaggedCheckInNotifications
            self.sendFriendRequestNotifications = sendFriendRequestNotifications
            self.sendCommentNotifications = sendCommentNotifications
        }

        enum CodingKeys: String, CodingKey {
            case id
            case sendReactionNotifications = "send_reaction_notifications"
            case sendTaggedCheckInNotifications = "send_tagged_check_in_notifications"
            case sendFriendRequestNotifications = "send_friend_request_notifications"
            case sendCommentNotifications = "send_comment_notifications"
        }
    }
}
