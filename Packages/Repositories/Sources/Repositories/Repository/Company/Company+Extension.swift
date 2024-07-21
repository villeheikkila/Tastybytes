import Foundation
import Models

extension Company: Queryable {
    private static let saved = "id, name, is_verified"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.companies, [saved, ImageEntity.getQuery(.saved(.companyLogos))], withTableName)
        case let .joinedBrandSubcategoriesOwner(withTableName):
            buildQuery(
                .companies,
                [
                    saved,
                    Company.getQuery(.saved(true)),
                    Brand.getQuery(.joined(true)),
                    ImageEntity.getQuery(.saved(.companyLogos)),
                ],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .companies,
                [
                    saved,
                    ImageEntity.getQuery(.saved(.companyLogos)),
                    Company.EditSuggestion.getQuery(.joined(true)),
                    Company.getQuery(.saved(true)),
                    Report.getQuery(.joined(true)),
                    modificationInfoFragment,
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}

extension Company.EditSuggestion: Queryable {
    private static let savedEditSuggestion = "id, name, created_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
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
