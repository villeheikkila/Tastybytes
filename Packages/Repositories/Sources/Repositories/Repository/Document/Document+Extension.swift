import Foundation
import Models

extension Document {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.documents.rawValue
        let saved = "document"

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
