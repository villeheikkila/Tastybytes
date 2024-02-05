import Foundation
import Models

extension Document {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "document"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.documents, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
