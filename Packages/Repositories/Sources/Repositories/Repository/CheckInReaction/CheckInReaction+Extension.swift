import Foundation
import Models

extension CheckInReaction: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id"

        switch queryType {
        case let .joinedProfileCheckIn(withTableName):
            return buildQuery(
                .checkInReactions,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))],
                withTableName
            )
        case let .joinedProfile(withTableName):
            return buildQuery(.checkInReactions, [saved, Profile.getQuery(.minimal(true))], withTableName)
        }
    }

    enum QueryType {
        case joinedProfile(_ withTableName: Bool)
        case joinedProfileCheckIn(_ withTableName: Bool)
    }
}
