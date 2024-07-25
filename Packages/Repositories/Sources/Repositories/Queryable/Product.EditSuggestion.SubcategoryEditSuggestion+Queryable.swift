import Models

extension Product.EditSuggestion.SubcategoryEditSuggestion: Queryable {
    private static let saved = "id, delete"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .productEditSuggestionSubcategories,
                [
                    saved,
                    Subcategory.getQuery(.joinedCategory(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
