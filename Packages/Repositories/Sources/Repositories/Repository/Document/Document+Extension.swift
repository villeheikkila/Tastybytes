import Foundation
import Models

extension Document: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "document"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.documents, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
