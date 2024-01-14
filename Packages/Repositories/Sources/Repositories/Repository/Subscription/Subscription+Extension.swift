import Foundation
import Models

extension SubscriptionGroup {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.subscriptionGroups.rawValue
        let saved = "name, group_id"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Subscription.getQuery(.saved(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
    }
}

extension Subscription {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.subscriptions.rawValue
        let saved = "name, product_id, group_id, priority"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }
}
