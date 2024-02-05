import Foundation
import Models

extension AppConfig {
    static func getQuery(_ queryType: QueryType) -> String {
        let saved = "base_url, feedback_email, privacy_policy_url, copyright_holder, copyright_time_range, minimum_supported_version, app_id"

        switch queryType {
        case let .saved(withTableName):
            return queryWithTableName(.appConfigs, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
