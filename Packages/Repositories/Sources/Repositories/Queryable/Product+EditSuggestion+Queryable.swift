import Models

extension Product.EditSuggestion: Queryable {
    private static let saved = "id, created_at, name, description, is_discontinued"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .productEditSuggestions,
                [
                    saved,
                    buildQuery(name: "products", foreignKey: "products!product_edit_suggestions_product_id_fkey", [Product.getQuery(.joinedBrandSubcategories(false))]),
                    buildQuery(name: "duplicate_of", foreignKey: "fk_duplicate_product_id", [Product.getQuery(.joinedBrandSubcategories(false))]),
                    Profile.getQuery(.minimal(true)),
                    Category.getQuery(.saved(true)),
                    SubBrand.getQuery(.joinedBrand(true)),
                    Product.EditSuggestion.SubcategoryEditSuggestion.getQuery(.joined(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
