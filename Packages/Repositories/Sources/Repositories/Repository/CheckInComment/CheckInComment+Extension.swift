import Foundation
import Models

extension CheckInComment {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.checkInComments.rawValue
        let saved = "id, content, created_at"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedProfile(withTableName):
            return queryWithTableName(tableName, [saved, Profile.getQuery(.minimal(true))].joinComma(), withTableName)
        case let .joinedCheckIn(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case joinedProfile(_ withTableName: Bool)
        case joinedCheckIn(_ withTableName: Bool)
    }
}
