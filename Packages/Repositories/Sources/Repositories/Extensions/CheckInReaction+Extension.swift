import Foundation
import Models

extension CheckInReaction {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.checkInReactions.rawValue
        let saved = "id"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedProfileCheckIn(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        case let .joinedProfile(withTableName):
            return queryWithTableName(tableName, [saved, Profile.getQuery(.minimal(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joinedProfile(_ withTableName: Bool)
        case joinedProfileCheckIn(_ withTableName: Bool)
    }
}
