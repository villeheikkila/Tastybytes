import Foundation
import Models

extension SubBrand {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.subBrands.rawValue
        let saved = "id, name, is_verified"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))].joinComma(),
                withTableName
            )
        case let .joinedBrand(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Brand.getQuery(.joinedCompany(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedBrand(_ withTableName: Bool)
    }
}
