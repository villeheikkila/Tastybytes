import Models

extension Product.Variant: Queryable {
    private static let saved = "id"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joinedCompany(withTableName):
            buildQuery(.productVariants, [saved, Company.getQuery(.saved(true))], withTableName)
        case let .joinedProduct(withTableName):
            buildQuery(.productVariants, [saved, Product.getQuery(.joinedBrandSubcategories(true))], withTableName)
        }
    }

    enum QueryType {
        case joinedCompany(_ withTableName: Bool)
        case joinedProduct(_ withTableName: Bool)
    }
}
