import Foundation
import Models

extension Subcategory {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, is_verified"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.subcategories, [saved], withTableName)
        case let .joinedCategory(withTableName):
            return queryWithTableName(.subcategories, [saved, Category.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joinedCategory(_ withTableName: Bool)
    }
}
