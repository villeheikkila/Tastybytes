import Foundation
import Models

extension Friend {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.friends.rawValue
        let joined =
            """
              id, status, sender:user_id_1 (\(Profile.getQuery(.minimal(false)))),\
              receiver:user_id_2 (\(Profile.getQuery(.minimal(false))))
            """

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(tableName, joined, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}
