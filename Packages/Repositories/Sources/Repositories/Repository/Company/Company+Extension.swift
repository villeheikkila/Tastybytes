import Foundation
import Models

extension Company: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, is_verified"
        let owner = buildQuery(.companies, [saved], true)

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.companies, [saved, ImageEntity.getQuery(.saved(.companyLogos))], withTableName)
        case let .detailed(withTableName):
            return buildQuery(.companies, [saved, ImageEntity.getQuery(.saved(.companyLogos)), Company.EditSuggestion.getQuery(.joined(true)), modificationInfoFragment], withTableName)
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
        case detailed(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
    }
}

extension Company.EditSuggestion: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let savedEditSuggestion = "id, name, created_at"

        return switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .companyEditSuggestions,
                [savedEditSuggestion, Company.getQuery(.saved(true)), Profile.getQuery(.minimal(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
