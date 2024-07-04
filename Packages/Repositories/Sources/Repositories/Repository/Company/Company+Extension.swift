import Foundation
import Models

extension Company: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let editSuggestionTable = "company_edit_suggestions"
        let saved = "id, name, is_verified"
        let owner = buildQuery(.companies, [saved], true)

        switch queryType {
        case .editSuggestionTable:
            return editSuggestionTable
        case let .saved(withTableName):
            return buildQuery(.companies, [saved, ImageEntity.getQuery(.saved(.companyLogos))], withTableName)
        case let .management(withTableName):
            return buildQuery(.companies, [saved, "created_at", ImageEntity.getQuery(.saved(.companyLogos)), Profile.getQuery(.minimal(true))], withTableName)
        case let .joinedBrandSubcategoriesOwner(withTableName):
            return buildQuery(
                .companies,
                [saved, owner, Brand.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.companyLogos))],
                withTableName
            )
        }
    }

    enum QueryType {
        case editSuggestionTable
        case saved(_ withTableName: Bool)
        case management(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
    }
}
