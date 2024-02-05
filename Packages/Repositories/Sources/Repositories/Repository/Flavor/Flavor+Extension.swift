import Foundation
import Models

extension Flavor: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.flavors, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
