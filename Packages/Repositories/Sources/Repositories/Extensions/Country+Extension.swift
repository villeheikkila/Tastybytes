import Foundation
import Models

extension Country {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.countries.rawValue
        let saved = "country_code, name, emoji"

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
