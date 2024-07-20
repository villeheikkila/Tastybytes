import Foundation
import Models

extension CheckInComment: Queryable {
    private static let saved = "id, content, created_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joinedProfile(withTableName):
            buildQuery(.checkInComments, [saved, Profile.getQuery(.minimal(true))], withTableName)
        case let .joinedCheckIn(withTableName):
            buildQuery(
                .checkInComments,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joinedProfile(_ withTableName: Bool)
        case joinedCheckIn(_ withTableName: Bool)
    }
}
