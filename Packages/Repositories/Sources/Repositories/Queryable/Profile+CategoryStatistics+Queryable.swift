import Models

extension Profile.CategoryStatistics {
    static func getQuery(_ queryType: QueryPart) -> String {
        switch queryType {
        case .value:
            "id, name, icon, count"
        }
    }

    enum QueryPart {
        case value
    }
}
