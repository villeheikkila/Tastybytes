import Models

extension Brand: Queryable {
    private static let saved = "id, name, is_verified"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.brands, [saved, Logo.getQuery(.saved(true))], withTableName)
        case let .savedProductCount(withTableName):
            buildQuery(
                .brands,
                [saved, Logo.getQuery(.saved(true)), "product_count"],
                withTableName
            )
        case let .joinedSubBrands(withTableName):
            buildQuery(.brands, [saved, SubBrand.getQuery(.saved(true)), Logo.getQuery(.saved(true))], withTableName)
        case let .joined(withTableName):
            buildQuery(.brands, [saved, SubBrand.getQuery(.joined(true)), Logo.getQuery(.saved(true))], withTableName)
        case let .joinedCompany(withTableName):
            buildQuery(.brands, [saved, Company.getQuery(.saved(true)), Logo.getQuery(.saved(true))], withTableName)
        case let .joinedSubBrandsCompany(withTableName):
            buildQuery(
                .brands,
                [
                    saved,
                    SubBrand.getQuery(.saved(true)),
                    Company.getQuery(.saved(true)),
                    Logo.getQuery(.saved(true))
                ],
                withTableName
            )
        case let .detailed(withTableName):
            buildQuery(
                .brands,
                [
                    saved,
                    SubBrand.getQuery(.joined(true)),
                    Company.getQuery(.saved(true)),
                    Logo.getQuery(.saved(true)),
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
        case savedProductCount(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedSubBrands(_ withTableName: Bool)
        case joinedCompany(_ withTableName: Bool)
        case joinedSubBrandsCompany(_ withTableName: Bool)
        case detailed(_ withTableName: Bool)
    }
}
