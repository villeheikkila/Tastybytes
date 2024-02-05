import Foundation
import Models

extension CheckInReaction {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id"

        switch queryType {
        case let .joinedProfileCheckIn(withTableName):
            return queryWithTableName(
                .checkInReactions,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))],
                withTableName
            )
        case let .joinedProfile(withTableName):
            return queryWithTableName(.checkInReactions, [saved, Profile.getQuery(.minimal(true))], withTableName)
        }
    }

    enum QueryType {
        case joinedProfile(_ withTableName: Bool)
        case joinedProfileCheckIn(_ withTableName: Bool)
    }
}
