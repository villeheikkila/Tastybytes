import Foundation
import Models

extension Document: Queryable {
    private static let saved = "document"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.documents, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
