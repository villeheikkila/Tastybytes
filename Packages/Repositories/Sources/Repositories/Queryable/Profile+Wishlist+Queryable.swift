import Models

extension Profile.Wishlist: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .profileWishlistItems,
                [Product.getQuery(.joinedBrandSubcategories(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
