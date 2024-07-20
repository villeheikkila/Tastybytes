import Foundation
import Models

extension Friend: Queryable {
    private static let saved = "id, status"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .joined(withTableName):
            buildQuery(.friends, [saved, buildQuery(name: "sender", foreignKey: "user_id_1", [Profile.getQuery(.minimal(false))]), buildQuery(name: "receiver", foreignKey: "user_id_2", [Profile.getQuery(.minimal(false))])], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
