import Foundation
import Models

extension Role: Queryable {
    private static let saved = "id, name"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(.roles, [saved, Permission.getQuery(.saved(true))], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
