import Foundation
import Models

extension Friend: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let joined =
            """
              id, status, sender:user_id_1 (\(Profile.getQuery(.minimal(false)))),\
              receiver:user_id_2 (\(Profile.getQuery(.minimal(false))))
            """

        switch queryType {
        case let .joined(withTableName):
            return buildQuery(.friends, [joined], withTableName)
        }
    }

    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}
