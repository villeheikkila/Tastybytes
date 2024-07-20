import Foundation
import Models

extension CheckInReaction: Queryable {
    private static let saved = "id"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joinedProfileCheckIn(withTableName):
            buildQuery(
                .checkInReactions,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))],
                withTableName
            )
        case let .joinedProfile(withTableName):
            buildQuery(.checkInReactions, [saved, Profile.getQuery(.minimal(true))], withTableName)
        }
    }

    enum QueryType {
        case joinedProfile(_ withTableName: Bool)
        case joinedProfileCheckIn(_ withTableName: Bool)
    }
}
