import Foundation
import Models

extension Models.Notification: Queryable {
    private static let saved = "id, message, created_at, seen_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case .joined:
            buildQuery(.notifications, [
                saved,
                CheckIn.Reaction.getQuery(.joinedProfileCheckIn(true)),
                Notification.CheckInTaggedProfiles.getQuery(.joined(true)),
                Friend.getQuery(.joined(true)),
                CheckIn.Comment.getQuery(.joinedCheckIn(true)),
            ], false)
        }
    }

    enum QueryType {
        case joined
    }
}

extension Profile.PushNotification: Queryable {
    private static let saved = "device_token, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications, send_friend_request_notifications, send_comment_notifications"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.profilePushNotifications, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
