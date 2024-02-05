import Foundation
import Models

extension Flavor {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.flavors, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
