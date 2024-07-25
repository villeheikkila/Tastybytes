import Models

extension Company.EditSuggestion: Queryable {
    private static let savedEditSuggestion = "id, name, created_at"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(
                .companyEditSuggestions,
                [savedEditSuggestion, Company.getQuery(.saved(true)), Profile.getQuery(.minimal(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
