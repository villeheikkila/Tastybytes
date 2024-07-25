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
