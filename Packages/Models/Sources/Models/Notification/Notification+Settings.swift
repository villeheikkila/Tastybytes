public import Tagged

public extension Notification {
    enum DeliveryType: String, CaseIterable, Codable, Sendable, Identifiable {
        case disabled
        case inApp = "in-app"
        case pushNotification = "push-notification"
        
        public var id: String {
            rawValue
        }
    }
}

public extension Notification {
    struct Settings: Codable, Sendable {
        public let id: Profile.Id
        public let deviceToken: DeviceToken.Id
        public let reactions: Notification.DeliveryType
        public let taggedCheckIn: Notification.DeliveryType
        public let friendRequest: Notification.DeliveryType
        public let checkInComment: Notification.DeliveryType

        enum CodingKeys: String, CodingKey {
            case id = "p_profile_id"
            case deviceToken = "p_device_token"
            case reactions = "p_send_reaction_notifications"
            case taggedCheckIn = "p_send_tagged_check_in_notifications"
            case friendRequest = "p_send_friend_request_notifications"
            case checkInComment = "p_send_comment_notifications"
        }

        public init(id: Profile.Id, deviceToken: DeviceToken.Id, reactions: Notification.DeliveryType, taggedCheckIn: Notification.DeliveryType, friendRequest: Notification.DeliveryType, checkInComment: Notification.DeliveryType) {
            self.id = id
            self.deviceToken = deviceToken
            self.reactions = reactions
            self.taggedCheckIn = taggedCheckIn
            self.friendRequest = friendRequest
            self.checkInComment = checkInComment
        }

        public init(profileSettings: Profile.Settings, pushNotificationSettings: Profile.PushNotificationSettings) {
            deviceToken = pushNotificationSettings.deviceToken
            id = profileSettings.id
            reactions = profileSettings.sendReactionNotifications ? pushNotificationSettings.sendReactionNotifications ? .pushNotification : .inApp : .disabled
            checkInComment = profileSettings.sendCommentNotifications ? pushNotificationSettings.sendCheckInCommentNotifications ? .pushNotification : .inApp : .disabled
            taggedCheckIn = profileSettings.sendTaggedCheckInNotifications ? pushNotificationSettings.sendTaggedCheckInNotifications ? .pushNotification : .inApp : .disabled
            friendRequest = profileSettings.sendFriendRequestNotifications ? pushNotificationSettings.sendFriendRequestNotifications ? .pushNotification : .inApp : .disabled
        }

        public func copyWith(
            reactions: Notification.DeliveryType? = nil,
            taggedCheckIn: Notification.DeliveryType? = nil,
            friendRequest: Notification.DeliveryType? = nil,
            checkInComment: Notification.DeliveryType? = nil
        ) -> Self {
            .init(
                id: id,
                deviceToken: deviceToken,
                reactions: reactions ?? self.reactions,
                taggedCheckIn: taggedCheckIn ?? self.taggedCheckIn,
                friendRequest: friendRequest ?? self.friendRequest,
                checkInComment: checkInComment ?? self.checkInComment
            )
        }
    }
}
