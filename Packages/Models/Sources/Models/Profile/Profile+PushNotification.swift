public extension Profile {
    struct PushNotification: Codable, Identifiable, Sendable {
        public var id: String { deviceToken }

        public let deviceToken: String
        public let sendReactionNotifications: Bool
        public let sendTaggedCheckInNotifications: Bool
        public let sendFriendRequestNotifications: Bool
        public let sendCheckInCommentNotifications: Bool

        enum CodingKeys: String, CodingKey {
            case deviceToken = "device_token"
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
        ) -> Self {
            .init(deviceToken: deviceToken,
                  sendReactionNotifications: sendReactionNotifications ?? self.sendReactionNotifications,
                  sendTaggedCheckInNotifications: sendTaggedCheckInNotifications ?? self
                      .sendTaggedCheckInNotifications,
                  sendFriendRequestNotifications: sendFriendRequestNotifications ?? self
                      .sendFriendRequestNotifications,
                  sendCheckInCommentNotifications: sendCheckInCommentNotifications ?? self
                      .sendCheckInCommentNotifications)
        }
    }
}
