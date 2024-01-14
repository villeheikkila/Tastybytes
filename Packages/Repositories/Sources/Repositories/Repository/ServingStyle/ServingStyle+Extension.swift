import Foundation
import Models

extension ServingStyle {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.servingStyles.rawValue
        let saved = "id, name"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
