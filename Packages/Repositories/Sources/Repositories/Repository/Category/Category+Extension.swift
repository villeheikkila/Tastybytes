import Foundation
import Models

extension Models.Category {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, icon"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.categories, [saved], withTableName)
        case let .joinedSubcaategoriesServingStyles(withTableName):
            return queryWithTableName(
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
