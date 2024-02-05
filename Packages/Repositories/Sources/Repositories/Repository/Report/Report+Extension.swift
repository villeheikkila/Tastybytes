import Foundation
import Models

extension Report: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, message"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.reports, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
