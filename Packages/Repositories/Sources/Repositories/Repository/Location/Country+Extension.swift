import Foundation
import Models

extension Country: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "country_code, name, emoji"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.countries, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
