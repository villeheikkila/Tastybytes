import Foundation
import Models

extension Brand {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, is_verified"

        switch queryType {
        case let .joinedSubBrands(withTableName):
            return queryWithTableName(.brands, [saved, SubBrand.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joined(withTableName):
            return queryWithTableName(.brands, [saved, SubBrand.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joinedCompany(withTableName):
            return queryWithTableName(.brands, [saved, Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joinedSubBrandsCompany(withTableName):
            return queryWithTableName(
                .brands,
                [saved, SubBrand.getQuery(.joined(true)), Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
        case joinedSubBrands(_ withTableName: Bool)
        case joinedCompany(_ withTableName: Bool)
        case joinedSubBrandsCompany(_ withTableName: Bool)
    }
}
