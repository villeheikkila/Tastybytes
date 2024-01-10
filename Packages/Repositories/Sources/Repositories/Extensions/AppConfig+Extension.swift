import Foundation
import Models

extension AppConfig {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.appConfigs.rawValue
        let saved = "base_url, feedback_email, privacy_policy_url, copyright_holder, copyright_time_range, minimum_supported_version, app_id"

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
