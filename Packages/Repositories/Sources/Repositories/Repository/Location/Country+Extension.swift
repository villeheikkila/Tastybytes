import Foundation
import Models

extension Country {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "country_code, name, emoji"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.countries, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
