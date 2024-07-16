import Foundation
import Models

extension SubBrand: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, includes_brand_name, is_verified"

        return switch queryType {
        case let .saved(withTableName):
            buildQuery(.subBrands, [saved], withTableName)
        case let .detailed(withTableName):
            buildQuery(
                .subBrands,
                [saved, "created_at", Profile.getQuery(.minimal(true)), Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
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
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedBrand(_ withTableName: Bool)
    }
}
