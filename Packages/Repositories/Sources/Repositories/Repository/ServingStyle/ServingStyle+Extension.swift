import Foundation
import Models

extension ServingStyle: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.servingStyles, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
