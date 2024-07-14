import Foundation
import Models

extension Subcategory: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, is_verified"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.subcategories, [saved], withTableName)
        case let .detailed(withTableName):
            return buildQuery(.subcategories, [saved, "created_at", Profile.getQuery(.minimal(true))], withTableName)
        case let .joinedCategory(withTableName):
            return buildQuery(.subcategories, [saved, Category.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
        case joinedCategory(_ withTableName: Bool)
    }
}
