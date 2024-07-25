import Models

extension Permission: Queryable {
    private static let saved = "id, name"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.permissions, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
