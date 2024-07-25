import Models

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
