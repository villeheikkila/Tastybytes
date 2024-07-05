import Foundation
import Models

extension Brand: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name, is_verified"

        switch queryType {
        case let .joinedSubBrands(withTableName):
            return buildQuery(.brands, [saved, SubBrand.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joined(withTableName):
            return buildQuery(.brands, [saved, SubBrand.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joinedCompany(withTableName):
            return buildQuery(.brands, [saved, Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joinedSubBrandsCompany(withTableName):
            return buildQuery(
                .brands,
                [saved, SubBrand.getQuery(.joined(true)), Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))],
                withTableName
            )
        case let .detailed(withTableName):
            return buildQuery(
                .brands,
                [saved, "created_at", SubBrand.getQuery(.joined(true)), Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos)),
                 buildQuery(name: "profiles", foreignKey: "created_by", [Profile.getQuery(.minimal(false))])],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
        case joinedSubBrands(_ withTableName: Bool)
        case joinedCompany(_ withTableName: Bool)
        case joinedSubBrandsCompany(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}
