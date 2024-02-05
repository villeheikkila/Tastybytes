import Foundation
import Models

extension SubscriptionGroup: Queryable {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "name, group_id"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.subscriptionGroups, [saved], withTableName)
        case let .joined(withTableName):
            return buildQuery(
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
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "name, product_id, group_id, priority"

        switch queryType {
        case let .saved(withTableName):
            return buildQuery(.subscriptionProducts, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
