import Foundation
import Models

extension Company {
    static func getQuery(_ queryType: QueryType) -> String {
        let editSuggestionTable = "company_edit_suggestions"
        let saved = "id, name, is_verified"
        let owner = queryWithTableName(.companies, [saved], true)

        switch queryType {
        case .editSuggestionTable:
            return editSuggestionTable
        case let .saved(withTableName):
            return queryWithTableName(.companies, [saved, ImageEntity.getQuery(.saved(.companyLogos))], withTableName)
        case let .joinedBrandSubcategoriesOwner(withTableName):
            return queryWithTableName(
                .companies,
                [saved, owner, Brand.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.companyLogos))],
                withTableName
            )
        }
    }

    enum QueryType {
        case editSuggestionTable
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
    }
}
