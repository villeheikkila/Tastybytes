import Foundation
import Models

extension ServingStyle {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, name"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.servingStyles, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
