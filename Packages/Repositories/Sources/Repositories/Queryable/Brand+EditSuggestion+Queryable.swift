import Models

extension Brand.EditSuggestion: Queryable {
    private static let saved = "id, name, created_at, resolved_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .brandEditSuggestions,
                [saved, Brand.getQuery(.saved(true)), Profile.getQuery(.minimal(true)), Company.getQuery(.saved(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
