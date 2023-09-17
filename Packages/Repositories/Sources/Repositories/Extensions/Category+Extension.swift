import Foundation
import Models

extension Models.Category {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.categories.rawValue
        let servingStyleTableName = Database.Table.categoryServingStyles.rawValue
        let saved = "id, name, icon"

        switch queryType {
        case .tableName:
            return tableName
        case .servingStyleTableName:
            return servingStyleTableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedSubcaategoriesServingStyles(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Subcategory.getQuery(.saved(true)), ServingStyle.getQuery(.saved(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case servingStyleTableName
        case saved(_ withTableName: Bool)
        case joinedSubcaategoriesServingStyles(_ withTableName: Bool)
    }
}
