import Foundation
import Models

extension Subcategory {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.subcategories.rawValue
        let saved = "id, name, is_verified"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedCategory(withTableName):
            return queryWithTableName(tableName, [saved, Category.getQuery(.saved(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joinedCategory(_ withTableName: Bool)
    }
}
