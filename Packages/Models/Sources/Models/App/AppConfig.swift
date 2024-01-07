import Foundation

public struct AppConfig: Hashable, Codable, Sendable {
    public let baseUrl: URL
    public let privacyPolicyUrl: URL
    public let feedbackEmail: String
    public let copyrightHolder: String
    public let copyrightTimeRange: String
    public let minimumSupportedVersion: String

    public init(baseUrl: URL, privacyPolicyUrl: URL, feedbackEmail: String, copyrightHolder: String, copyrightTimeRange: String, minimumSupportedVersion: String) {
        self.baseUrl = baseUrl
        self.privacyPolicyUrl = privacyPolicyUrl
        self.feedbackEmail = feedbackEmail
        self.copyrightHolder = copyrightHolder
        self.copyrightTimeRange = copyrightTimeRange
        self.minimumSupportedVersion = minimumSupportedVersion
    }

    enum CodingKeys: String, CodingKey {
        case baseUrl = "base_url"
        case privacyPolicyUrl = "privacy_policy_url"
        case feedbackEmail = "feedback_email"
        case copyrightHolder = "copyright_holder"
        case copyrightTimeRange = "copyright_time_range"
        case minimumSupportedVersion = "minimum_supported_version"
    }
}
