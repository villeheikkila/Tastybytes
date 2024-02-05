import Foundation
import Models

extension Report {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "id, message"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.reports, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
