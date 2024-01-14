import Foundation
import Models

extension Models.Notification {
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
                Notification.CheckInTaggedProfiles.getQuery(.joined(true)),
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

extension ProfilePushNotification {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profilePushNotifications.rawValue
        let saved =
            "device_token, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications, send_friend_request_notifications, send_comment_notifications"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
