import Foundation
import Models

extension Models.Category: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, icon"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.categories, [saved], withTableName)
        case let .joinedSubcaategoriesServingStyles(withTableName):
            return buildQuery(
                .categories,
                [saved, Subcategory.getQuery(.saved(true)), ServingStyle.getQuery(.saved(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joinedSubcaategoriesServingStyles(_ withTableName: Bool)
    }
}
