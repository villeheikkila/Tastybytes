import Foundation
import Models

extension AppConfig: Queryable {
    private static let saved = "base_url, feedback_email, privacy_policy_url, terms_of_service_url, copyright_holder, copyright_time_range, minimum_supported_version, app_id, is_under_maintenance"

    static func getQuery(_ queryType: QueryType) -> String {
        switch queryType {
        case let .saved(withTableName):
            buildQuery(.appConfigs, [saved], withTableName)
        }
    }

    enum QueryType {
        case saved(_ withTableName: Bool)
    }
}
