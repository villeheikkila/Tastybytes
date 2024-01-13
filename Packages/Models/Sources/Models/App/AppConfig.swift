import Foundation

public struct AppConfig: Hashable, Codable, Sendable {
    public let appId: String
    public let baseUrl: URL
    public let privacyPolicyUrl: URL
    public let feedbackEmail: String
    public let copyrightHolder: String
    public let copyrightTimeRange: String
    public let minimumSupportedVersion: AppVersion

    public init(appId: String, baseUrl: URL, privacyPolicyUrl: URL, feedbackEmail: String, copyrightHolder: String, copyrightTimeRange: String, minimumSupportedVersion: AppVersion) {
        self.appId = appId
        self.baseUrl = baseUrl
        self.privacyPolicyUrl = privacyPolicyUrl
        self.feedbackEmail = feedbackEmail
        self.copyrightHolder = copyrightHolder
        self.copyrightTimeRange = copyrightTimeRange
        self.minimumSupportedVersion = minimumSupportedVersion
    }

    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case baseUrl = "base_url"
        case privacyPolicyUrl = "privacy_policy_url"
        case feedbackEmail = "feedback_email"
        case copyrightHolder = "copyright_holder"
        case copyrightTimeRange = "copyright_time_range"
        case minimumSupportedVersion = "minimum_supported_version"
    }

    public var appleStoreUrl: URL? {
        URL(string: "https://apps.apple.com/app/id\(appId)")
    }
}
