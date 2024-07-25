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
                    Brand.getQuery(.joinedCompany(true)),
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
