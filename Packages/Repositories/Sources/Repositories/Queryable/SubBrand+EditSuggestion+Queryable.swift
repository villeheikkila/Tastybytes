import Models

extension SubBrand.EditSuggestion: Queryable {
    private static let saved = "id, created_at, name, includes_brand_name"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .subBrandEditSuggestion,
                [
                    saved,
                    Brand.getQuery(.saved(true)),
                    SubBrand.getQuery(.joinedBrand(true)),
                    Profile.getQuery(.minimal(true)),
                ],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
