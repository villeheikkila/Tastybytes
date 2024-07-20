import Foundation
import Models

extension SubscriptionGroup: Queryable {
    private static let saved = "name, group_id"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.subscriptionGroups, [saved], withTableName)
        case let .joined(withTableName):
            buildQuery(
                .subscriptionGroups,
                [saved, SubscriptionProduct.getQuery(.saved(true))],
                withTableName
            )
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
    }
}

extension SubscriptionProduct: Queryable {
    private static let saved = "name, product_id, group_id, priority"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.subscriptionProducts, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
