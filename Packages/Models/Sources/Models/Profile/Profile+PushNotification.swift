public extension Profile {
    struct PushNotificationSettings: Codable, Sendable {
        public let deviceToken: DeviceToken.Id
        public let createdBy: Profile.Id
        public let sendReactionNotifications: Bool
        public let sendTaggedCheckInNotifications: Bool
        public let sendFriendRequestNotifications: Bool
        public let sendCheckInCommentNotifications: Bool

        public init(
            deviceToken: DeviceToken.Id,
            createdBy: Profile.Id,
            sendReactionNotifications: Bool,
            sendTaggedCheckInNotifications: Bool,
            sendFriendRequestNotifications: Bool,
            sendCheckInCommentNotifications: Bool
        ) {
            self.deviceToken = deviceToken
            self.createdBy = createdBy
            self.sendReactionNotifications = sendReactionNotifications
            self.sendTaggedCheckInNotifications = sendTaggedCheckInNotifications
            self.sendFriendRequestNotifications = sendFriendRequestNotifications
            self.sendCheckInCommentNotifications = sendCheckInCommentNotifications
        }

        enum CodingKeys: String, CodingKey {
            case deviceToken = "device_token"
            case createdBy = "created_by"
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
                  createdBy: createdBy,
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
