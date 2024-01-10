import Foundation

public struct AppConfig: Hashable, Codable, Sendable {
    public let baseUrl: URL
    public let privacyPolicyUrl: URL
    public let feedbackEmail: String
    public let copyrightHolder: String
    public let copyrightTimeRange: String
    public let minimumSupportedVersion: AppVersion

    public init(baseUrl: URL, privacyPolicyUrl: URL, feedbackEmail: String, copyrightHolder: String, copyrightTimeRange: String, minimumSupportedVersion: AppVersion) {
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

public struct AppVersion: Codable, Sendable, Hashable, Comparable {
    let major: Int
    let minor: Int
    let patch: Int
    let build: Int

    public init(with versionString: String, buildVersion: Int) throws {
        try self.init(components: AppVersion.decode(versionString), buildVersion: buildVersion)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let versionString = try container.decode(String.self)
        try self.init(components: AppVersion.decode(versionString))
    }

    private static func decode(_ versionString: String) -> [Int] {
        versionString.split(separator: ".").compactMap { Int($0) }
    }

    private init(components: [Int], buildVersion: Int = 0) throws {
        guard components.count == 3 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid Version. Expected format: 'major.minor.patch'"))
        }

        major = components[0]
        minor = components[1]
        patch = components[2]
        build = buildVersion
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major {
            lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            lhs.minor < rhs.minor
        } else {
            lhs.patch < rhs.patch
        }
    }
}
