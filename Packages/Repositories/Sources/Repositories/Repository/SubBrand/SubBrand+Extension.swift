import Foundation
import Models

extension SubBrand: Queryable {
    private static let saved = "id, name, includes_brand_name, is_verified"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.subBrands, [saved], withTableName)
        case let .joined(withTableName):
            buildQuery(
                .subBrands,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        case let .joinedBrand(withTableName):
            buildQuery(
                .subBrands,
                [saved, Brand.getQuery(.joinedCompany(true))],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .subBrands,
                [
                    saved,
                    Product.getQuery(.joinedBrandSubcategories(true)),
                    SubBrand.EditSuggestion.getQuery(.joined(true)),
                    Report.getQuery(.joined(true)),
                    modificationInfoFragment,
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedBrand(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}

extension SubBrand.EditSuggestion: Queryable {
    private static let saved = "id, created_at, name, includes_brand_name"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .subBrandEditSuggestion,
                [
                    saved,
                    Brand.getQuery(.saved(true)),
                    SubBrand.getQuery(.joinedBrand(true)),
                    Profile.getQuery(.minimal(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
