import Foundation
import Models

extension Brand {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.brands.rawValue
        let saved = "id, name, is_verified, logo_file"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedSubBrands(withTableName):
            return queryWithTableName(tableName, [saved, SubBrand.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))].joinComma(), withTableName)
        case let .joined(withTableName):
            return queryWithTableName(tableName, [saved, SubBrand.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.brandLogos))].joinComma(), withTableName)
        case let .joinedCompany(withTableName):
            return queryWithTableName(tableName, [saved, Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))].joinComma(), withTableName)
        case let .joinedSubBrandsCompany(withTableName):
            return queryWithTableName(
                tableName,
                [saved, SubBrand.getQuery(.joined(true)), Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
        case joinedSubBrands(_ withTableName: Bool)
        case joinedCompany(_ withTableName: Bool)
        case joinedSubBrandsCompany(_ withTableName: Bool)
    }
}
