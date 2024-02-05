import Foundation
import Models

extension CheckInComment: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, content, created_at"

        switch queryType {
        case let .joinedProfile(withTableName):
            return buildQuery(.checkInComments, [saved, Profile.getQuery(.minimal(true))], withTableName)
        case let .joinedCheckIn(withTableName):
            return buildQuery(
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
