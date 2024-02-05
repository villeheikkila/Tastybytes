import Foundation
import Models

extension Models.Notification {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, message, created_at, seen_at"

        switch queryType {
        case .joined:
            return queryWithTableName(.notifications, [
                saved,
                CheckInReaction.getQuery(.joinedProfileCheckIn(true)),
                Notification.CheckInTaggedProfiles.getQuery(.joined(true)),
                Friend.getQuery(.joined(true)),
                CheckInComment.getQuery(.joinedCheckIn(true)),
            ], false)
        }
    }

    enum QueryType {
        case joined
    }
}

extension ProfilePushNotification {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved =
            "device_token, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications, send_friend_request_notifications, send_comment_notifications"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.profilePushNotifications, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
