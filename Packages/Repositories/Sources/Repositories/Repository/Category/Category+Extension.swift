import Foundation
import Models

extension Models.Category: Queryable {
    private static let saved = "id, name, icon"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.categories, [saved], withTableName)
        case let .joinedSubcaategoriesServingStyles(withTableName):
            buildQuery(
                .categories,
                [saved, Subcategory.getQuery(.detailed(true)), ServingStyle.getQuery(.saved(true))],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .categories,
                [
                    saved,
                    Subcategory.getQuery(.detailed(true)),
                    ServingStyle.getQuery(.saved(true)),
                    modificationInfoFragment,
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joinedSubcaategoriesServingStyles(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}
