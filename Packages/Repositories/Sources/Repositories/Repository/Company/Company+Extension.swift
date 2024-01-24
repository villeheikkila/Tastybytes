import Foundation
import Models

extension Company {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.companies.rawValue
        let editSuggestionTable = "company_edit_suggestions"
        let saved = "id, name, logo_file, is_verified"
        let owner = queryWithTableName(tableName, saved, true)

        switch queryType {
        case .tableName:
            return tableName
        case .editSuggestionTable:
            return editSuggestionTable
        case let .saved(withTableName):
            return queryWithTableName(tableName, [saved, ImageEntity.getQuery(.saved(.companyLogos))].joinComma(), withTableName)
        case let .joinedBrandSubcategoriesOwner(withTableName):
            return queryWithTableName(
                tableName,
                [saved, owner, Brand.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.companyLogos))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case editSuggestionTable
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
    }
}
