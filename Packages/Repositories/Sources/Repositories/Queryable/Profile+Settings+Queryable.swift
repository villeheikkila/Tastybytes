import Models

extension Profile.Settings: Queryable {
    private static let saved = "id, send_reaction_notifications, send_tagged_check_in_notifications, send_friend_request_notifications, send_comment_notifications"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.profileSettings, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
