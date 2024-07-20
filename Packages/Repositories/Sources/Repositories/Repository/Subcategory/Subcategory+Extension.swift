import Foundation
import Models

extension Subcategory: Queryable {
    private static let saved = "id, name, is_verified"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.subcategories, [saved], withTableName)
        case let .detailed(withTableName):
            buildQuery(
                .subcategories,
                [saved, Category.getQuery(.saved(true)), modificationInfoFragment],
                withTableName
            )
        case let .joinedCategory(withTableName):
            buildQuery(.subcategories, [saved, Category.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
        case joinedCategory(_ withTableName: Bool)
    }
}
