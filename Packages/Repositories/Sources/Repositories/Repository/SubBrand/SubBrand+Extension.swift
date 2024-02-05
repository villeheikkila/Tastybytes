import Foundation
import Models

extension SubBrand {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, is_verified"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.subBrands, [saved], withTableName)
        case let .joined(withTableName):
            return queryWithTableName(
                .subBrands,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        case let .joinedBrand(withTableName):
            return queryWithTableName(
                .subBrands,
                [saved, Brand.getQuery(.joinedCompany(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedBrand(_ withTableName: Bool)
    }
}
