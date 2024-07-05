import Foundation
import Models

extension SubBrand: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, is_verified"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.subBrands, [saved], withTableName)
        case let .detailed(withTableName):
            return buildQuery(
                .subBrands,
                [saved, "created_at", Profile.getQuery(.minimal(true)), Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        case let .joined(withTableName):
            return buildQuery(
                .subBrands,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        case let .joinedBrand(withTableName):
            return buildQuery(
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
