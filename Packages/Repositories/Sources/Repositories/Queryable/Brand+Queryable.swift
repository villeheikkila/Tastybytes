import Models

extension Brand: Queryable {
    private static let saved = "id, name, is_verified"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.brands, [saved, ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joinedSubBrands(withTableName):
            buildQuery(.brands, [saved, SubBrand.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joined(withTableName):
            buildQuery(.brands, [saved, SubBrand.getQuery(.joined(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joinedCompany(withTableName):
            buildQuery(.brands, [saved, Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))], withTableName)
        case let .joinedSubBrandsCompany(withTableName):
            buildQuery(
                .brands,
                [saved, SubBrand.getQuery(.joined(true)), Company.getQuery(.saved(true)), ImageEntity.getQuery(.saved(.brandLogos))],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .brands,
                [
                    saved,
                    SubBrand.getQuery(.joined(true)),
                    Company.getQuery(.saved(true)),
                    ImageEntity.getQuery(.saved(.brandLogos)),
                    Brand.EditSuggestion.getQuery(.joined(true)),
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
        case joinedSubBrands(_ withTableName: Bool)
        case joinedCompany(_ withTableName: Bool)
        case joinedSubBrandsCompany(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}
