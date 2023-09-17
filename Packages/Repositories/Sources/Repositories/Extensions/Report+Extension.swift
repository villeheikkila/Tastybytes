import Foundation
import Models

extension Report {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.reports.rawValue
        let saved = "id, message"

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
