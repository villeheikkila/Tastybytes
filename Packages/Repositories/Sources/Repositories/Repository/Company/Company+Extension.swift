import Foundation
import Models

extension Company: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, is_verified"
        let savedEditSuggestion = "id, name, created_at"
        let owner = buildQuery(.companies, [saved], true)

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.companies, [saved, ImageEntity.getQuery(.saved(.companyLogos))], withTableName)
        case let .management(withTableName):
            return buildQuery(.companies, [saved, "created_at", ImageEntity.getQuery(.saved(.companyLogos)), Profile.getQuery(.minimal(true)), Company.getQuery(.editSuggestion(true))], withTableName)
        case let .editSuggestion(withTableName):
            return buildQuery(.companyEditSuggestions, [savedEditSuggestion, Profile.getQuery(.minimal(true))], withTableName)
        case let .joinedBrandSubcategoriesOwner(withTableName):
            return buildQuery(
                .companies,
                [saved, owner, Brand.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.companyLogos))],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case management(_ withTableName: Bool)
        case editSuggestion(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
    }
}
