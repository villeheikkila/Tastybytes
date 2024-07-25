import Foundation
import Models

extension Country: Queryable {
    private static let saved = "country_code, name, emoji"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.countries, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
