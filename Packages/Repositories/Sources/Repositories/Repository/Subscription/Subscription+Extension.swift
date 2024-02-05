import Foundation
import Models

extension SubscriptionGroup {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "name, group_id"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.subscriptionGroups, [saved], withTableName)
        case let .joined(withTableName):
            return queryWithTableName(
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

extension SubscriptionProduct {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "name, product_id, group_id, priority"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.subscriptionProducts, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
