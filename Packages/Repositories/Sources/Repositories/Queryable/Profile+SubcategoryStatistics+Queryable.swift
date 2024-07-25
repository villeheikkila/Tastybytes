import Models

extension Profile.SubcategoryStatistics {
    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            "id, name, count"
        }
    }

    enum QueryPart {
        case value
    }
}
